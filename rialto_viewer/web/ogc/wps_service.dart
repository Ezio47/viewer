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

    WpsService(Uri server, {Uri proxyUri: null, String description: null})
            : super("WPS", server, proxyUri: proxyUri, description: description);


    Future<OgcDocument> getProcessDescription(String processName) {
        var c = new Completer<OgcDocument>();

        if (!processIdentifiers.containsKey(processName)) {
            throw new ArgumentError("unknown WPS service: $processName");
        }
        final String processIdentifier = processIdentifiers[processName];

        _sendKvpServerRequest("DescribeProcess", ["identifier=$processIdentifier"]).then((OgcDocument ogcDoc) {

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

            if (ogcDoc is! OgcProcessDescriptions_15) {
                Hub.error("Error parsing WPS process description response document");
                c.complete(null);
                return;
            }

            var descs = ogcDoc as OgcProcessDescriptions_15;
            var descList = descs.descriptions.where((d) => d.identifier == processIdentifier).toList();

            if (descList == null || descList.isEmpty || descList.length > 1) {
                Hub.error("Error parsing OWS Process Description response document");
            }

            var desc = descList[0];
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

        _sendKvpServerRequest("Execute", parms).then((OgcDocument ogcDoc) {

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

            c.complete(ogcDoc);
        });

        return c.future;
    }

    // returns the job ID, and will have already created a status object for that ID (even in
    // the case of any failures)
    Future<int> doWpsRequest(WpsRequestData data) {

        if (data.operation != WpsRequestData.EXECUTE_PROCESS) {
            throw new ArgumentError("invalid WPS request");
        }

        var c = new Completer<int>();

        assert(data.parameters.length == 3);
        String name = data.parameters[0];
        Map<String, dynamic> inputs = data.parameters[1];
        List<String> outputs = data.parameters[2];

        var request = _hub.wpsJobManager.createStatusObject(this);
        request.onSuccess = (_) => log("success event");
        request.onFailure = (_) => log("failure event");
        request.onTimeout = (_) => log("timeout event");

        executeProcess(name, inputs, outputs).then((ogcDoc) {

            if (ogcDoc == null) {
                request.code = OgcStatus_55.STATUS_SYSTEMFAILURE;
                c.complete(request.id);
                return;
            }

            if (ogcDoc is OgcExceptionReportDocument) {
                request.code = OgcStatus_55.STATUS_FAILED;
                request.exceptionTexts = ogcDoc.exceptionTexts;
                c.complete(request.id);
                return;
            }

            var resp = ogcDoc as OgcExecuteResponseDocument_54;

            request.statusLocation = Uri.parse(resp.statusLocation);
            request.proxyUri = proxyUri;
            request.processCreationTime = DateTime.parse(resp.status.creationTime);
            request.code = resp.status.code;

            c.complete(request.id);
        });

        return c.future;
    }
}