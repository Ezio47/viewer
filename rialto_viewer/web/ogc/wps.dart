// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class OwsService {
    final String service;
    final String server;
    final String proxy;
    final String description;
    Hub _hub;
    Http.Client _client;

    OwsService(String this.service, String this.server, {String this.proxy, String this.description}) : _hub = Hub.root;

    void open() {
        _client = new BHttp.BrowserClient();
    }

    void close() {
        _client.close();
    }

    Future<Xml.XmlDocument> _doServerRequest(String requestType, [List<String> params = null]) {

        String operation = "?Request=$requestType&Service=$service";
        if (params != null) {
            params.forEach((s) => operation += "&$s");
        }

        Completer c = new Completer<Xml.XmlDocument>();

        String wps = Uri.encodeFull(server + operation);
        log("wps server request: $operation");

        var url = wps;

        if (proxy != null) {
            var magic = "/x?q=";
            url = proxy + magic + '"' + wps + '"';
            log(url);
        }

        var f = _client.get(url).then((response) {
            String s = response.body;
            var doc = Xml.parse(s);
            c.complete(doc);
        }).catchError((e) {
            Hub.error(e);
        });

        return c.future;
    }
}


class WpsService extends OwsService {

    WpsService(String server, {String proxy, String description})
            : super("WPS", server, proxy: proxy, description: description) {
        _hub.events.WpsRequest.subscribe(_handleWpsRequest);
    }

    Future<OgcDocument> getCapabilitiesAsync() {
        var c = new Completer<OgcDocument>();

        _doServerRequest("GetCapabilities").then((Xml.XmlDocument doc) {
            var caps = OgcDocument.parse(doc);
            if (caps == null) Hub.error("error parsing capabilities response document");
            c.complete(caps);
        });

        return c.future;
    }

    Future<OgcDocument> getProcessDescriptionAsync(String processIdentifier) {
        var c = new Completer<OgcDocument>();

        _doServerRequest("DescribeProcess", ["identifier=$processIdentifier"]).then((Xml.XmlDocument doc) {
            var ret = OgcDocument.parse(doc);
            var desc;

            if (ret is Ogc_ExceptionReport) {
                log("exception report!");
                c.complete(ret);
            } else {
                assert(ret is Ogc_ProcessDescriptions);
                desc = ret.descriptions.where((d) => d.identifier == processIdentifier);

                if (desc == null ||
                        desc.isEmpty ||
                        desc.length > 1) Hub.error("error parsing process description response document");

                c.complete(desc.first);
            }
        });

        return c.future;
    }

    Future<OgcDocument> executeProcessAsync(String processName, Map<String, String> params) {
        var c = new Completer<OgcDocument>();

        String identifier = "Identifier=$processName";
        String dataInputs = "DataInputs=alpha=17;beta=11";

        _doServerRequest("Execute", [identifier, dataInputs]).then((Xml.XmlDocument doc) {
            var resp = OgcDocument.parse(doc);
            if (resp == null) Hub.error("error parsing execute response document");
            c.complete(resp);
        });

        return c.future;
    }

    void getViewshedAsync(double observerLon, double observerLat, double radius) {
        var c = new Completer<OgcDocument>();

        var params = {
            "observerLon": observerLon.toString(),
            "observerLat": observerLat.toString(),
            "radius": radius.toString()
        }
        ;
        executeProcessAsync("Viewshed", params).then((OgcDocument doc) {
            if (doc is Ogc_ExceptionReport) {
                log("viewshed returned exception report");
            }
            log(doc);
            c.complete(doc);
        });

        return c.future;
    }

    void _handleWpsRequest(WpsRequestData data) {
        log("WPS request: ${WpsRequestData.name[data.type]}, params=${data.params.length}");
    }
}
