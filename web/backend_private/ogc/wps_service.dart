// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend.private;


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


    Future<OgcDocument> _executeProcessWork(String processName, Map<String, dynamic> inputs, List<String> outputs,
            {Map<String, String> options: null}) {
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

        var opts = new Map<String, String>();
        if (options != null) {
            options.forEach((k, v) => opts[k.toLowerCase()] = v.toLowerCase());
        }

        opts.putIfAbsent("storeexecuteresponse", () => "true");
        opts.putIfAbsent("lineage", () => "true");
        opts.putIfAbsent("status", () => "true");

        var parms = [identifierKV, dataInputsKV, dataOutputsKV, responseDocumentKV];
        opts.forEach((k, v) => parms.add("$k=$v"));

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

    static String inferDatatype(String abstract, String datatype) {
        if (abstract != null) {
            if (abstract.endsWith("[int]")) return "int";
            if (abstract.endsWith("[double]")) return "double";
            if (abstract.endsWith("[string]")) return "string";
            assert(!abstract.endsWith("]"));
        }

        if (datatype == null) {
            return "string";
        }

        switch (datatype)
        {
            case "":
                return "string";
            case "xs:double":
                return "double";
            case "int":         // (geoserver says "int", not "xs:int"?)
            case "xs:int":
                return "int";
            default:
                assert(false);
                return null;
        }
    }

    Future<String> testConnection() async {
        String s = "";

        OgcDocument doc = await getCapabilities();

        if (doc is! OgcCapabilitiesDocument_7) {
            s += "GetCapabilities check: FAILED";
            return s;
        }
        var capabilities = doc as  OgcCapabilitiesDocument_7;
        var processes = capabilities.processOfferings.processes;

        var procs = processes.where((p) => p.identifier.startsWith("py:"));

        for (var proc in procs) {
            OgcDocument doc = await this.describeProcess(proc.identifier);
            OgcProcessDescription_16 descr = doc as OgcProcessDescription_16;
            var inputs = descr.dataInput.dataInputs;
            for (OgcInputDescription_19 input in inputs) {
                var dt = inferDatatype(input.abstract, input.literalData.datatype);
                var nam = input.identifier;
                print("IN {$nam} ${dt}");
            }
            var outputs = descr.processOutputs.outputData;
            for (var output in outputs) {
                var nam = output.identifier;
                var dt = inferDatatype(output.abstract, output.literalOutput.datatype);
                print("OUT {$nam} ${dt}");
            }
        }

        return s;

        OgcDocument description = await this.describeProcess("groovy:wpshelloworld");

        if (description is! OgcProcessDescription_16) {
            s += "DescribeProcess check: FAILED\n";
            if (description is OgcExceptionReportDocument) {
                s += description.exceptionTexts.fold("", (prev, cur) => "$prev  Exception: $cur\n");
            }
            return s;
        }

        final title = (description as OgcProcessDescription_16).title;
        if (title != "HelloWorld") {
            s += "DescribeProcess check: FAILED (titled \"$title\")\n";
            return s;
        }

        s += "DescribeProcess check: passed (titled \"$title\")\n";

        final inputs = {
            "alpha": alphaValue
        };
        final outputs = ["omega"];
        final options = {
            "storeexecuteresponse": "false",
            "lineage": "false",
            "status": "false"
        };
        OgcDocument exec = await _executeProcessWork("groovy:wpshelloworld", inputs, outputs, options: options);

        if (exec is! OgcExecuteResponseDocument_54) {
            s += "ExecuteProcess check: FAILED\n";
            if (exec is OgcExceptionReportDocument) {
                s += exec.exceptionTexts.fold("", (prev, cur) => "$prev  Exception: $cur\n");
            }
            return s;
        }

        String omega;
        try {
            var execRespDoc = (exec as OgcExecuteResponseDocument_54);
            var procOuts = execRespDoc.processOutputs;
            var outsDataList = procOuts.outputDataList;
            var outData = outsDataList.first;
            var data = outData.data;
            var lit = data.literalData;
            var val = lit.value;
            omega = val;
        } catch (_) {
            s += "ExecuteProcess check: FAILED\n";
            return s;
        }

        if (omega != omegaValue) {
            s += "ExecuteProcess check: FAILED (returned \"$omega\")\n";
            return s;
        }

        s += "ExecuteProcess check: passed (returned \"$omega\")\n";

        return s;
    }

    Future<String> testConnection2() async {
        final alphaValue = "Yow!";
        final omegaValue = "!woY";

        String s = "";

        OgcDocument capabilities = await getCapabilities();

        if (capabilities is! OgcCapabilitiesDocument_7) {
            s += "GetCapabilities check: FAILED";
            return s;
        }

        final numProcesses = (capabilities as OgcCapabilitiesDocument_7).processOfferings.processes.length;
        s += "GetCapabilities check: passed ($numProcesses processes)\n";

        OgcDocument description = await this.describeProcess("groovy:wpshelloworld");

        if (description is! OgcProcessDescription_16) {
            s += "DescribeProcess check: FAILED\n";
            if (description is OgcExceptionReportDocument) {
                s += description.exceptionTexts.fold("", (prev, cur) => "$prev  Exception: $cur\n");
            }
            return s;
        }

        final title = (description as OgcProcessDescription_16).title;
        if (title != "HelloWorld") {
            s += "DescribeProcess check: FAILED (titled \"$title\")\n";
            return s;
        }

        s += "DescribeProcess check: passed (titled \"$title\")\n";

        final inputs = {
            "alpha": alphaValue
        };
        final outputs = ["omega"];
        final options = {
            "storeexecuteresponse": "false",
            "lineage": "false",
            "status": "false"
        };
        OgcDocument exec = await _executeProcessWork("groovy:wpshelloworld", inputs, outputs, options: options);

        if (exec is! OgcExecuteResponseDocument_54) {
            s += "ExecuteProcess check: FAILED\n";
            if (exec is OgcExceptionReportDocument) {
                s += exec.exceptionTexts.fold("", (prev, cur) => "$prev  Exception: $cur\n");
            }
            return s;
        }

        String omega;
        try {
            var execRespDoc = (exec as OgcExecuteResponseDocument_54);
            var procOuts = execRespDoc.processOutputs;
            var outsDataList = procOuts.outputDataList;
            var outData = outsDataList.first;
            var data = outData.data;
            var lit = data.literalData;
            var val = lit.value;
            omega = val;
        } catch (_) {
            s += "ExecuteProcess check: FAILED\n";
            return s;
        }

        if (omega != omegaValue) {
            s += "ExecuteProcess check: FAILED (returned \"$omega\")\n";
            return s;
        }

        s += "ExecuteProcess check: passed (returned \"$omega\")\n";

        return s;
    }
}
