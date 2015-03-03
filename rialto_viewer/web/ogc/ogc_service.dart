// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class OwsService {
    final String service;
    final Uri server;
    final Uri proxyUri;
    final String description;
    Hub _hub;

    OwsService(String this.service, Uri this.server, {Uri this.proxyUri: null, String this.description: null})
            : _hub = Hub.root;

    void open() {
    }

    void close() {
    }

    Future<OgcDocument> _sendKvpServerRequest(String requestType, List<String> params) {

        String operation = "?Request=$requestType&Service=$service";
        if (params != null) {
            params.forEach((s) => operation += "&$s");
        }

        Completer c = new Completer<OgcDocument>();

        String s = Uri.encodeComponent(server.toString() + operation);

        var uri = Uri.parse(s);

        //log("ows server request: $uri");

        Comms.httpGet(uri, proxyUri: proxyUri).then((Http.Response response) {
            if (response.statusCode != 200) {
                Hub.error("server request failed");
                c.complete(null);
                return;
            }

            String text = response.body;
            //log(text);
            try {
                var doc = OgcDocument.parseString(text);
                c.complete(doc);
            } catch (e) {
                Hub.error("Unable to parse server response", object: e);
                c.complete(null);
            }

        }).catchError((e) {
            Hub.error("Server request failed", object: e, info: {});
            c.complete(null);
            return;
        });

        return c.future;
    }


    Future<OgcDocument> getCapabilities() {
        var c = new Completer<OgcDocument>();

        _sendKvpServerRequest("GetCapabilities", []).then((OgcDocument ogcDoc) {

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
