// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend.private;


/// Generalized notion of an OWS service.
///
/// Allows for doing a GetCapabilities call and for sending an arbitray GET request to the service.
///
/// The WPS service class is derived from this.
class OgcService {
    final String service;
    final Uri server;
    final Uri proxyUri;
    final String description;
    RialtoBackend _backend;

    OgcService(RialtoBackend this._backend, String this.service, Uri this.server, {Uri this.proxyUri: null, String this.description: null});

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

        String s = server.toString() + operation;
        if (proxyUri != null) {
           // s = Uri.encodeComponent(s);
        }

        var uri = Uri.parse(s);

        //log("ows server request: $uri");

        Utils.httpGet(uri, proxyUri: proxyUri).then((Http.Response response) {
            if (response.statusCode != 200) {
                RialtoBackend.error("server request failed");
                c.complete(null);
                return;
            }

            String text = response.body;
            //log(text);
            try {
                var doc = OgcDocument.parseString(text);
                c.complete(doc);
            } catch (e) {
                RialtoBackend.error("Unable to parse server response", e);
                c.complete(null);
            }
        });

        return c.future;
    }


    Future<OgcDocument> getCapabilities() {
        var c = new Completer<OgcDocument>();

        _sendKvpServerRequest("GetCapabilities", []).then((OgcDocument ogcDoc) {

            if (ogcDoc == null) {
                RialtoBackend.error("Error parsing OWS Capabilities response document");
                c.complete(null);
                return;
            }

            c.complete(ogcDoc);
        });

        return c.future;
    }

    String dump() {
        String s = "";
        s += "Service: $service\n";
        s += "Server: $server\n";
        return s;
    }
}
