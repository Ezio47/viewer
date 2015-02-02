// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class Wps {
    final String _proxy;
    final String _server;
    final String _description;

    Hub _hub;
    Http.Client _client;

    Wps(String this._proxy, String this._server, [String this._description]) {
        _hub = Hub.root;

        _hub.events.WpsRequest.subscribe(_handleWpsRequest);
    }

    void open() {
        _client = new BHttp.BrowserClient();
    }

    void close() {
        _client.close();
    }


    Future<OgcDocument_WpsCapabilities> getCapabilitiesAsync() {
        var c = new Completer<OgcDocument_WpsCapabilities>();

        _doServerRequest("?Request=GetCapabilities&Service=WPS").then((Xml.XmlDocument doc) {
            var caps = OgcDocument.parseWpsCapabilities(doc);
            log(caps);
            c.complete(caps);
        });

        return c.future;
    }

    Future<OgcDocument_WpsProcessDescription> getProcessDescriptionAsync(String processName) {
        var c= new Completer<OgcDocument_WpsProcessDescription>();

        _doServerRequest("?Request=DescribeProcess&Service=WPS&identifier=$processName").then((Xml.XmlDocument doc) {
            Xml.XmlDocument doc = Xml.parse(s);
            var descs = OgcDocument.parseWpsProcessDescriptions(doc);
            var desc = descs.descriptions[processName];
            log(desc);
            c.complete(desc);
        });

        return c.future;
    }

    Future<OgcDocument_WpsProcessDescription> executeProcessAsync(String processName, List<String> params) {
        var c= new Completer<OgcDocument_WpsProcessDescription>();

        _runWpsOperation("?Request=DescribeProcess&Service=WPS&identifier=processName").then((String s) {
            Xml.XmlDocument doc = Xml.parse(s);
            var descs = OgcDocument.parseWpsProcessDescriptions(doc);
            var desc = descs.descriptions[processName];
            log(desc);
            c.complete(desc);
        });

        return c.future;
    }

    void getViewshedAsync(double observerLon, double observerLat, double radius) {
        assert(false);
        _runWpsOperation("?Request=GetCapabilities&Service=WPS").then((String s) {
            //print(s);

            Xml.XmlDocument doc = Xml.parse(s);
            capabilities = OgcDocument.parseWpsCapabilities(doc);

            log(capabilities);
        });
    }

    void _handleWpsRequest(WpsRequestData data) {
        log("WPS request: ${WpsRequestData.name[data.type]}, params=${data.params.length}");
    }

    Future<Xml.XmlDocument> _doServerRequest( operation) {

        // ?Request=GetCapabilities&Service=WPS

        Completer c = new Completer<String>();

        String wps = Uri.encodeFull(_server + operation);
        print("wps server: $wps");

        var url = _proxy + "/x?q=\"" + wps + "\"";

        var f = _client.get(url).then((response) {
            //print(r.runtimeType);
            //print("response.body);

            String s = response.body;
            var doc = Xml.parse(s);
            c.complete(doc);
        }).catchError((e) {
            print(e);
            assert(false);
        });

        return c.future;
    }
}
