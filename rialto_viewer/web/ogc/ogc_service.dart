// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class OwsService {
    final String service;
    final Uri server;
    final Uri proxy;
    final String description;
    Hub _hub;
    Http.Client _client;

    OwsService(String this.service, Uri this.server, {Uri this.proxy, String this.description}) : _hub = Hub.root;

    void open() {
        _client = new BHttp.BrowserClient();
    }

    void close() {
        _client.close();
    }

    Future<Xml.XmlDocument> _sendKvpServerRequest(String requestType, [List<String> params = null]) {

        String operation = "?Request=$requestType&Service=$service";
        if (params != null) {
            params.forEach((s) => operation += "&$s");
        }

        Completer c = new Completer<Xml.XmlDocument>();

        String s = Uri.encodeComponent(server.toString() + operation);

        if (proxy != null) {
            s = proxy.toString() + "?" + s;
        }

        var uri = Uri.parse(s);

        log("ows server request: $uri");

        var f = _client.get(uri).then((response) {
            String s = response.body;
            log(s);
            try {
                var doc = Xml.parse(s);
                c.complete(doc);
            } catch (e) {
                Hub.error("Unable to parse server response", object: e);
                c.complete(null);
            }
        }).catchError((e) {
            Hub.error("Server request failed", object: e, info: {});
        });

        return c.future;
    }


    Future<OgcDocument> getCapabilities() {
        var c = new Completer<OgcDocument>();

        _sendKvpServerRequest("GetCapabilities").then((Xml.XmlDocument xmlDoc) {
            if (xmlDoc == null) {
                c.complete(null);
                return;
            }
            var ogcDoc = OgcDocument.parse(xmlDoc);
            if (ogcDoc == null) {
                Hub.error("Error parsing OWS Capabilities response document");
                c.complete(null);
                return;
            }
            c.complete(ogcDoc);
        });

        return c.future;
    }
}