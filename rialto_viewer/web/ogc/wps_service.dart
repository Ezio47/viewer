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

    Map<String, WpsRequestStatus> requestStatus = new Map<String, WpsRequestStatus>();

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

            var ogcDoc = OgcDocument.parseXml(xmlDoc);
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

            assert(ogcDoc is OgcProcessDescriptions_15);
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

        String responseDocumentKV = "ResponseDocument="; //gamma;delta
        outputs.forEach((k) => responseDocumentKV += "$k;");
        responseDocumentKV = responseDocumentKV.substring(0, responseDocumentKV.length - 1); // remove trailing ';'

        String storeExecRespKV = "StoreExecuteResponse=true";
        String lineageKV = "Lineage=true";
        String statusKV = "Status=true";

        var parms = [
                identifierKV,
                dataInputsKV,
                dataOutputsKV,
                responseDocumentKV,
                storeExecRespKV,
                lineageKV,
                statusKV];

        _sendKvpServerRequest("Execute", parms).then((Xml.XmlDocument xmlDoc) {
            if (xmlDoc == null) {
                c.complete(null);
                return;
            }

            var ogcDoc = OgcDocument.parseXml(xmlDoc);
            if (ogcDoc == null) {
                Hub.error("Error parsing WPS process execution response document");
                c.complete(null);
                return;
            }

            if (ogcDoc is OgcExceptionReportDocument) {
                c.complete(ogcDoc);
                return;
            }

            if (ogcDoc is! OgcExecuteResponseDocument_54) {
                Hub.error("Error parsing WPS process execution response document");
                c.complete(ogcDoc);
                return;
            }

            var statusLoc = ogcDoc.statusLocation;
            //log(statusLoc);

            c.complete(ogcDoc);
        });

        return c.future;
    }


    // returns the job ID
    Future<String> doWpsRequest(WpsRequestData data) {

        if (data.operation != WpsRequestData.EXECUTE_PROCESS) {
            throw new ArgumentError("invalid WPS request");
        }

        var c = new Completer<String>();

        _hub.events.WpsRequestUpdate.fire(new WpsRequestUpdateData(1));

        assert(data.parameters.length == 3);
        String name = data.parameters[0];
        Map<String, dynamic> inputs = data.parameters[1];
        List<String> outputs = data.parameters[2];

        String id;

        executeProcess(name, inputs, outputs).then((ogcDoc) {

            if (ogcDoc is OgcExceptionReportDocument) {
                assert(false); // TODO
            } else if (ogcDoc is! OgcExecuteResponseDocument_54) {
                assert(false);
            } else {
                var resp = ogcDoc as OgcExecuteResponseDocument_54;
                id = resp.statusLocation; // TODO: is this the best unique ID we have?
                var url = Uri.parse(resp.statusLocation);
                var time = resp.status.creationTime;
                var code = resp.status.code;
                var request = new WpsRequestStatus(id, url, time, code);
                requestStatus[id] = request;
            }

            _hub.events.WpsRequestUpdate.fire(new WpsRequestUpdateData(-1));

            c.complete(id);
        });

        return c.future;
    }

    void test() {
        //OgcDocumentTests.test();
        //testCapabilities();
        //testDescribeHello();
        //testExecuteHello();
        //testDescribeViewshed();
        //testExecuteViewshed();
        testExecuteViewshed2();
    }

    void testCapabilities() {
        getCapabilities().then((OgcDocument doc) {
            assert(doc is OgcCapabilities_7);
            //log(doc.dump(0));
            assert(doc.dump(0).contains("Identifier: groovy:wpshello"));
        });
    }

    void testDescribeHello() {
        getProcessDescription("Hello").then((OgcDocument doc) {
            assert(doc is OgcProcessDescription_16);
            var desc = doc as OgcProcessDescription_16;
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
            assert(doc is OgcExecuteResponseDocument_54);
            OgcExecuteResponseDocument_54 resp = doc;
            var status = resp.status.processSucceeded;
            assert(status != null);
            OgcDataType_46 datatype = resp.processOutputs.outputData[0].data;
            OgcLiteralData_48 literalData = datatype.literalData;
            //log(literalData.dump(0));
            assert(literalData.value == "28.0");
        });
    }

    void testDescribeViewshed() {
        getProcessDescription("Viewshed").then((OgcDocument doc) {
            assert(doc is OgcProcessDescription_16);
            var desc = doc as OgcProcessDescription_16;
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
        var outputs = ["resultlon"];

        executeProcess("Viewshed", inputs, outputs).then((OgcDocument doc) {

            //log(doc.dump(0));

            if (doc is OgcExceptionReportDocument) {
                log(doc.dump(0));
                assert(false);
                return;
            }

            assert(doc is OgcExecuteResponseDocument_54);
            OgcExecuteResponseDocument_54 resp = doc;

            var status = resp.status;
            switch (status.code) {
                case OgcStatus_55.STATUS_ACCEPTED:
                    //log(status.dump(0));
                    break;
                case OgcStatus_55.STATUS_STARTED:
                    log(status.dump(0));
                    assert(false);
                    break;
                case OgcStatus_55.STATUS_SUCCEEDED:
                    log(status.dump(0));
                    assert(false);
                    OgcDataType_46 datatype = resp.processOutputs.outputData[0].data;
                    OgcLiteralData_48 literalData = datatype.literalData;
                    //log(literalData.dump(0));
                    assert(literalData.value == "99.0");
                    break;
                default:
                    assert(false);
            }

        });
    }

    void testExecuteViewshed2() {
        var params = new List(3);
        params[0] = "Viewshed";
        params[1] = {
            "pt1lon": 2.0,
            "pt1lat": 20.0,
            "pt2lon": 200.0,
            "pt2lat": 2000.0
        };
        params[2] = ["resultlon"];

        doWpsRequest(new WpsRequestData(WpsRequestData.EXECUTE_PROCESS, params)).then((id) {
            log("started: $id");

            //new Timer.periodic(new Duration(seconds: 5), (t) {
            new Timer.periodic(new Duration(seconds: 1), (_) {
                log("QUERIED!");

                var req = this.requestStatus[id];
                var url = req.statusLocation;
                var f = Comms.httpGet(url, proxy: this.proxy).then((response) {
                    var ogcDoc = OgcDocument.parseString(response.body);
                    log(ogcDoc.dump(0));
                });
            });
        });
    }
}


class WpsRequestStatus {
    final String id;
    final Uri statusLocation;
    final String creationTime;

    int code; // from OgcStatus_55 enums

    WpsRequestStatus(String this.id, Uri this.statusLocation, String this.creationTime, int code1) : code = code1;
}
