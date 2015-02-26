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

    Future<Xml.XmlDocument> _doServerRequest(String requestType, [List<String> params = null]) {

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

        log("wps server request: $uri");

        var f = _client.get(uri).then((response) {
            String s = response.body;
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
}


class WpsService extends OwsService {

    WpsService(Uri server, {Uri proxy, String description})
            : super("WPS", server, proxy: proxy, description: description);

    Future<OgcDocument> getCapabilitiesAsync() {
        var c = new Completer<OgcDocument>();

        _doServerRequest("GetCapabilities").then((Xml.XmlDocument xmlDoc) {
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

    Future<OgcDocument> getProcessDescriptionAsync(String processIdentifier) {
        var c = new Completer<OgcDocument>();

        _doServerRequest("DescribeProcess", ["identifier=$processIdentifier"]).then((Xml.XmlDocument xmlDoc) {
            if (xmlDoc == null) {
                c.complete(null);
                return;
            }

            var ogcDoc = OgcDocument.parse(xmlDoc);
            if (ogcDoc == null) {
                Hub.error("Error parsing WPS process description response document");
                c.complete(null);
                return;
            }

            if (ogcDoc is Ogc_ExceptionReport) {
                log("exception report!");
                c.complete(ogcDoc);
                return;
            }

            assert(ogcDoc is Ogc_ProcessDescriptions);
            var desc = ogcDoc.descriptions.where((d) => d.identifier == processIdentifier);

            if (desc == null || desc.isEmpty || desc.length > 1) {
                Hub.error("Error parsing OWS Process Description response document");
            }

            c.complete(desc.first);
        });

        return c.future;
    }

    Future<OgcDocument> executeProcessAsync(String processName, Map<String, dynamic> params) {
        var c = new Completer<OgcDocument>();

        String alpha, beta;

        if (processName == "Viewshed") { // TODO
            processName = "groovy:wpshello";
            alpha = params["observerLon"].toString();
            beta = params["observerLat"].toString();
        } else if (processName == "groovy:wpshello") {
            alpha = params["alpha"];
            beta = params["beta"];
        } else {
            throw new ArgumentError("unknown WPS service");
        }

        String identifier = "Identifier=$processName";
        String dataInputs = "DataInputs=alpha=$alpha;beta=$beta";

        _doServerRequest("Execute", [identifier, dataInputs]).then((Xml.XmlDocument xmlDoc) {
            if (xmlDoc == null) {
                c.complete(null);
                return;
            }

            var ogcDoc = OgcDocument.parse(xmlDoc);
            if (ogcDoc == null) {
                Hub.error("Error parsing WPS process execution response document");
                c.complete(null);
                return;
            }

            c.complete(ogcDoc);
        });

        return c.future;
    }

    Future<bool> _getViewshedAsync(double observerLon, double observerLat, double radius) {
        var c = new Completer<bool>();

        var params = {
            "observerLon": observerLon,
            "observerLat": observerLat,
            "radius": radius
        };

        executeProcessAsync("Viewshed", params).then((OgcDocument ogcDoc) {
            if (ogcDoc == null) {
                c.complete(null);
                return;
            }
            if (ogcDoc is Ogc_ExceptionReport) {
                log("viewshed returned exception report");
                log(ogcDoc);
                c.complete(false);
                return;
            }
            log(ogcDoc);
            c.complete(true);
        });

        return c.future;
    }

    Future doWpsRequest(WpsRequestData data) {
        if (data.type == WpsRequestData.VIEWSHED) {

            _hub.events.WpsRequestUpdate.fire(new WpsRequestUpdateData(1));

            double lon = data.params[0];
            double lat = data.params[1];
            double radius = data.params[2];
            _getViewshedAsync(lon, lat, radius).then((_) {

                var random = new Random();
                var msecs = 1000 + random.nextInt(3000);
                var duration = new Duration(milliseconds: msecs);
                new Timer(duration, () => _hub.events.WpsRequestUpdate.fire(new WpsRequestUpdateData(-1)));
                log("request done after $msecs ms");
            });
        } else {
            throw new ArgumentError("invalid WPS request");
        }

        return new Future((){});
    }
}
