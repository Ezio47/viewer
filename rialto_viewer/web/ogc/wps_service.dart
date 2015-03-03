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

    WpsService(Uri server, {Uri proxyUri: null, String description: null})
            : super("WPS", server, proxyUri: proxyUri, description: description);


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
                var request = new WpsRequestStatus(id, url, time, code, proxyUri: proxyUri);
                requestStatus[id] = request;
            }

            _hub.events.WpsRequestUpdate.fire(new WpsRequestUpdateData(-1));

            c.complete(id);
        });

        return c.future;
    }
}


class WpsRequestStatus {
    final String id;
    final Uri statusLocation;
    final String creationTime;
    final Uri proxyUri;

    int code; // from OgcStatus_55 enums
    String exception;
    OgcExecuteResponseDocument_54 result;

    var delay = new Duration(seconds: 2);

    WpsRequestStatus(String this.id, Uri this.statusLocation, String this.creationTime, int this.code, {Uri
            this.proxyUri: null}) {

        new Timer(delay, poll);
    }

    void poll() {

        log("polling...");

        var url = statusLocation;
        Comms.httpGet(url, proxyUri: proxyUri).then((response) {
            var ogcDoc = OgcDocument.parseString(response.body);
            //log(ogcDoc.dump(0));

            if (ogcDoc.isException) {
                code = OgcStatus_55.STATUS_EXCEPTIONED;
                exception = ogcDoc.exceptionString;
            } else {
                OgcExecuteResponseDocument_54 resp = ogcDoc;
                code = resp.status.code;
                result = resp;
            }

            if (!OgcStatus_55.isComplete(code)) {
                log("requeueing!");
                new Timer(delay, poll);
            } else {
                log("done!");
            }
        });
    }
}
