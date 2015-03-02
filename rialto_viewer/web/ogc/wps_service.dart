// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class WpsService extends OwsService {

    static final Map processIdentifiers = {
        "Viewshed": "groovy:wpsviewshed",
        "Hello": "groovy:wpshello",
        "org.ciesin.gis.wps.algorithms.PopStats": "org.ciesin.gis.wps.algorithms.PopStats",
        "org.ciesin.gis.wps.algorithms.PopStat": "org.ciesin.gis.wps.algorithms.PopStat"
    };


    WpsService(Uri server, {Uri proxy, String description})
            : super("WPS", server, proxy: proxy, description: description);


    Future<OgcDocument> getProcessDescription(String processName) {
        var c = new Completer<OgcDocument>();

        if (!processIdentifiers.containsKey(processName)) {
            throw new ArgumentError("unknown WPS service: $processName");
        }
        final String processIdentifier = processIdentifiers[processName];

        _sendKvpServerRequest("DescribeProcess", ["identifier=$processIdentifier"]).then((Xml.XmlDocument xmlDoc) {
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

            if (ogcDoc is OgcExceptionReportDocument) {
                //log("exception report!");
                c.complete(ogcDoc);
                return;
            }

            assert(ogcDoc is Ogc_ProcessDescriptions);
            var idesc = ogcDoc.descriptions.where((d) => d.identifier == processIdentifier);

            if (idesc == null || idesc.isEmpty || idesc.length > 1) {
                Hub.error("Error parsing OWS Process Description response document");
            }

            var desc = idesc.first;
            c.complete(desc);
        });

        return c.future;
    }


    Future<OgcDocument> executeProcess(String processName, Map<String, dynamic> inputs, List<String> outputs) {
        var c = new Completer<OgcDocument>();

        if (!processIdentifiers.containsKey(processName)) {
            throw new ArgumentError("unknown WPS service");
        }
        final processIdentifier = processIdentifiers[processName];

        String identifierKV = "Identifier=$processIdentifier";

        String dataInputsKV = "DataInputs="; //alpha=$alpha;beta=$beta
        inputs.forEach((k, v) => dataInputsKV += "$k=${v.toString()};");
        dataInputsKV = dataInputsKV.substring(0, dataInputsKV.length - 1); // remove trailing ';'

        String dataOutputsKV = "DataOutputs="; //gamma;delta
        outputs.forEach((k) => dataOutputsKV += "$k;");
        dataOutputsKV = dataOutputsKV.substring(0, dataOutputsKV.length - 1); // remove trailing ';'

        _sendKvpServerRequest("Execute", [identifierKV, dataInputsKV, dataOutputsKV]).then((Xml.XmlDocument xmlDoc) {
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


    Future<OgcDocument> doWpsRequest(WpsRequestData data) {
        var c = new Completer<OgcDocument>();

        if (data.operation == WpsRequestData.EXECUTE_PROCESS) {

            _hub.events.WpsRequestUpdate.fire(new WpsRequestUpdateData(1));

            assert(data.parameters.length == 3);
            String name = data.parameters[0];
            Map<String, dynamic> inputs = data.parameters[1];
            List<String> outputs = data.parameters[2];

            executeProcess(name, inputs, outputs).then((ogcDoc) {

                var random = new Random();
                var msecs = 1000 + random.nextInt(3000);
                var duration = new Duration(milliseconds: msecs);
                new Timer(duration, () => _hub.events.WpsRequestUpdate.fire(new WpsRequestUpdateData(-1)));
                log("request done after $msecs ms");
                c.complete(ogcDoc);
            });
        } else {
            throw new ArgumentError("invalid WPS request");
        }

        return c.future;
    }

    void test() {
        OgcDocumentTests.test();
        testCapabilities();
        testDescribeHello();
        testExecuteHello();
        testDescribeViewshed();
        testExecuteViewshed();
    }

    void testCapabilities() {
        getCapabilities().then((OgcDocument doc) {
            assert(doc is Ogc_Capabilities);
            //log(doc.dump(0));
            assert(doc.dump(0).contains("Identifier: groovy:wpshello"));
        });
    }

    void testDescribeHello() {
        getProcessDescription("Hello").then((OgcDocument doc) {
            assert(doc is Ogc_ProcessDescription);
            var desc = doc as Ogc_ProcessDescription;
            //log(desc.dump(0));
            assert(desc.title == "GeoScriptHello");
            assert(desc.dataInput.dataInputs[0].identifier == "alpha");
            assert(desc.dataInput.dataInputs[1].identifier == "beta");
            assert(desc.processOutputs.outputData[0].identifier == "gamma");
        });
    }

    void testExecuteHello() {
        var inputs = {
            "alpha": "17",
            "beta": "11"
        };
        var outputs = ["gamma"];

        executeProcess("Hello", inputs, outputs).then((OgcDocument doc) {
            assert(doc is OgcExecuteResponseDocument);
            OgcExecuteResponseDocument resp = doc;
            var status = resp.status.processSucceeded;
            assert(status != null);
            Ogc_DataType datatype = resp.processOutputs.outputData[0].data;
            Ogc_LiteralData48 literalData = datatype.literalData;
            //log(literalData.dump(0));
            assert(literalData.value == "28.0");
        });
    }

    void testDescribeViewshed() {
        getProcessDescription("Viewshed").then((OgcDocument doc) {
            assert(doc is Ogc_ProcessDescription);
            var desc = doc as Ogc_ProcessDescription;
            //log(desc.dump(0));
            assert(desc.title == "GeoScriptViewshed");
            var a = desc.dataInput.dataInputs.map((i) => i.identifier).toList();
            a.sort();
            var b = ["pt1lat", "pt1lon", "pt2lat", "pt2lon"];
            b.sort();
            for (int i = 0; i < 4; i++) {
                assert(a[i] == b[i]);
            }
            assert(desc.processOutputs.outputData[0].identifier == "resultlon");
        });
    }

    void testExecuteViewshed() {
        var inputs = {
            "pt1lon": "1.0",
            "pt1lat": "10",
            "pt2lon": "100.0",
            "pt2lat": "1000.0"
        };
        var outputs = ["resultLon"];

        executeProcess("Viewshed", inputs, outputs).then((OgcDocument doc) {
            //log(doc.dump(0));
            assert(doc is OgcExecuteResponseDocument);
            OgcExecuteResponseDocument resp = doc;
            var status = resp.status.processSucceeded;
            assert(status != null);
            Ogc_DataType datatype = resp.processOutputs.outputData[0].data;
            Ogc_LiteralData48 literalData = datatype.literalData;
            //log(literalData.dump(0));
            assert(literalData.value == "99.0");
        });
    }
}
