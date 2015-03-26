// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


/// Implementation of a WPS server.
///
/// Allows for getting process descriptions, executing processes, and so on.
class WpsService extends OgcService {

    WpsService(RialtoBackend backend, Uri server, {Uri proxyUri: null, String description: null})
            : super(backend, "WPS", server, proxyUri: proxyUri, description: description);


    Future<OgcDocument> _getProcessDescriptionWork(String processName) {
        var c = new Completer<OgcDocument>();

        _sendKvpServerRequest("DescribeProcess", ["identifier=$processName"]).then((OgcDocument ogcDoc) {

            if (ogcDoc == null) {
                RialtoBackend.error("Error parsing WPS process description response document");
                c.complete(null);
                return;
            }

            if (ogcDoc is OgcExceptionReportDocument) {
                //log("exception report!");
                c.complete(ogcDoc);
                return;
            }

            if (ogcDoc is! OgcProcessDescriptions_15) {
                RialtoBackend.error("Error parsing WPS process description response document");
                c.complete(null);
                return;
            }

            var descs = ogcDoc as OgcProcessDescriptions_15;
            var descList = descs.descriptions.where((d) => d.identifier == processName).toList();

            if (descList == null || descList.isEmpty || descList.length > 1) {
                RialtoBackend.error("Error parsing OWS Process Description response document");
            }

            var desc = descList[0];
            c.complete(desc);
        });

        return c.future;
    }


    Future<OgcDocument> _executeProcessWork(String processName, Map<String, dynamic> inputs, List<String> outputs) {
        var c = new Completer<OgcDocument>();

        String identifierKV = "Identifier=$processName";

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
                RialtoBackend.error("Error parsing WPS process execution response document");
                c.complete(null);
                return;
            }

            if (ogcDoc is OgcExceptionReportDocument) {
                c.complete(ogcDoc);
                return;
            }

            if (ogcDoc is! OgcExecuteResponseDocument_54) {
                RialtoBackend.error("Error parsing WPS process execution response document");
                c.complete(ogcDoc);
                return;
            }

            c.complete(ogcDoc);
        });

        return c.future;
    }

    /// Execute a WPS process
    ///
    /// Returns the job ID, and will have already created a status object for that ID (even in
    /// the case of any failures)
    Future<WpsJob> executeProcess(WpsExecuteProcessData data, {WpsJobResultHandler successHandler: null,
            WpsJobResultHandler errorHandler: null, WpsJobResultHandler timeoutHandler: null}) {

        var c = new Completer<WpsJob>();

        assert(data.parameters.length == 3);
        String name = data.parameters[0];
        Map<String, dynamic> inputs = data.parameters[1];
        List<String> outputs = data.parameters[2];

        var request = _backend.wpsJobManager.createJob(
                this,
                successHandler: successHandler,
                errorHandler: errorHandler,
                timeoutHandler: timeoutHandler);

        _executeProcessWork(name, inputs, outputs).then((ogcDoc) {

            if (ogcDoc == null) {
                request.code = OgcStatusCodes.systemFailure;
                request.stopPolling();
                c.complete(request);
                return;
            }

            if (ogcDoc is OgcExceptionReportDocument) {
                request.code = OgcStatusCodes.failed;
                request.exceptionTexts = ogcDoc.exceptionTexts;
                request.stopPolling();
                c.complete(request);
                return;
            }

            var resp = ogcDoc as OgcExecuteResponseDocument_54;

            request.statusLocation = Uri.parse(resp.statusLocation);
            request.proxyUri = proxyUri;
            request.processCreationTime = DateTime.parse(resp.status.creationTime);
            request.code = resp.status.code;

            request.startPolling();

            c.complete(request);
        });

        return c.future;
    }

    /// Issues a "describe process" request to the WPS server
    ///
    /// Returns the response document
    Future<OgcDocument> describeProcess(String processName) {
        return _getProcessDescriptionWork(processName);
    }
}
