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
        print("wps server request: $operation");

        var url = wps;

        if (proxy != null) {
            var magic = "/x?q=";
            url = proxy + magic + '"' + wps + '"';
            log(url);
        }

        var f = _client.get(url).then((response) {
            //print(r.runtimeType);
            //print("response.body);

            String s = response.body;
            var doc = Xml.parse(s);
            c.complete(doc);
        }).catchError((e) {
            print(e);
            assert(false); // TODO
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
            log(caps);
            c.complete(caps);
        });

        return c.future;
    }

    Future<OgcDocument> getProcessDescriptionAsync(String processName) {
        var c = new Completer<OgcDocument>();

        _doServerRequest("DescribeProcess", ["identifier=$processName"]).then((Xml.XmlDocument doc) {
            var ret = OgcDocument.parse(doc);
            var desc;

            if (ret is OgcDocument_WpsProcessDescriptions) {
                desc = ret.descriptions[processName];
            } else {
                desc = ret;
            }
            log(desc);
            c.complete(desc);
        });

        return c.future;
    }

    Future<OgcDocument> executeProcessAsync(String processName, List<String> params) {
        var c = new Completer<OgcDocument>();

        _doServerRequest("Execute", ["identifier=$processName"]).then((Xml.XmlDocument doc) {
            var resp = OgcDocument.parse(doc);
            log(resp);
            c.complete(resp);
        });

        return c.future;
    }

    void getViewshedAsync(double observerLon, double observerLat, double radius) {
        var c = new Completer<OgcDocument>();

        var params = ["observerLon=$observerLon", "observerLat=$observerLat", "radius=$radius"];
        executeProcessAsync("Viewshed", params).then((OgcDocument doc) {
            if (doc is OgcDocument_ExceptionReport) {
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
