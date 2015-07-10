// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend;

/// Implementation of a client for a WPS server.
///
/// Allows for getting process descriptions, executing processes, and so on.
class WpsService extends OgcService {
  Map<String, WpsProcess> processes = new Map<String, WpsProcess>();

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

  Future<OgcDocument> _executeProcessWork(WpsProcess process, Map<String, dynamic> inputs) {
    var c = new Completer<OgcDocument>();

    String identifierKV = "Identifier=${process.name}";

    String dataInputsKV = "DataInputs="; //alpha=$alpha;beta=$beta
    process.inputs.forEach((param) => dataInputsKV += "${param.name}=${inputs[param.name].toString()};");
    dataInputsKV = dataInputsKV.substring(0, dataInputsKV.length - 1); // remove trailing ';'

    String dataOutputsKV = "DataOutputs="; //gamma;delta
    process.outputs.forEach((param) => dataOutputsKV += "${param.name};");
    dataOutputsKV = dataOutputsKV.substring(0, dataOutputsKV.length - 1); // remove trailing ';'

    String responseDocumentKV = "ResponseDocument="; //gamma;delta
    process.outputs.forEach((param) => responseDocumentKV += "${param.name};");
    responseDocumentKV = responseDocumentKV.substring(0, responseDocumentKV.length - 1); // remove trailing ';'

    var opts = new Map<String, String>();
    opts.putIfAbsent("storeexecuteresponse", () => "true");
    opts.putIfAbsent("lineage", () => "true");
    opts.putIfAbsent("status", () => "true");

    var parms = [identifierKV, dataInputsKV, dataOutputsKV, responseDocumentKV];
    opts.forEach((k, v) => parms.add("$k=$v"));

    RialtoBackend.log(parms);
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
  Future<WpsJob> executeProcess(WpsProcess process, Map<String, dynamic> inputs,
      {WpsJobSuccessResultHandler successHandler: null, WpsJobErrorResultHandler failureHandler: null,
      WpsJobErrorResultHandler timeoutHandler: null}) {
    var c = new Completer<WpsJob>();

    var request = _backend.wpsJobManager.createJob(this, process,
        successHandler: successHandler, errorHandler: failureHandler, timeoutHandler: timeoutHandler);

    _executeProcessWork(process, inputs).then((ogcDoc) {
      if (ogcDoc == null) {
        request.jobStatus = OgcStatusCodes.systemFailure;
        request.stopPolling();
        c.complete(request);
        return;
      }

      if (ogcDoc is OgcExceptionReportDocument) {
        request.jobStatus = OgcStatusCodes.failed;
        request.exceptionTexts = ogcDoc.exceptionTexts;
        request.stopPolling();
        c.complete(request);
        return;
      }

      var resp = ogcDoc as OgcExecuteResponseDocument_54;

      request.statusLocation = Uri.parse(resp.statusLocation);
      request.proxyUri = proxyUri;
      request.jobCreationTime = DateTime.parse(resp.status.creationTime);
      request.jobStatus = resp.status.code;

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

  static WpsProcessParamDataType inferDatatype(String abstract, String datatype) {
    if (abstract != null) {
      if (abstract.endsWith("[int]")) return WpsProcessParamDataType.integer;
      if (abstract.endsWith("[double]")) return WpsProcessParamDataType.double;
      if (abstract.endsWith("[string]")) return WpsProcessParamDataType.string;
      assert(!abstract.endsWith("]"));
    }

    if (datatype == null) {
      return WpsProcessParamDataType.string;
    }

    switch (datatype) {
      case "":
        return WpsProcessParamDataType.string;
      case "xs:double":
        return WpsProcessParamDataType.double;
      case "int": // (geoserver says "int", not "xs:int"?)
      case "xs:int":
        return WpsProcessParamDataType.integer;
      default:
        assert(false);
        return null;
    }
  }

  Future readProcessList() async {
    OgcDocument doc = await getCapabilities();

    if (doc is! OgcCapabilitiesDocument_7) {
      RialtoBackend.error("GetCapabilities check: FAILED");
      return new Future.value(null);
    }
    var capabilities = doc as OgcCapabilitiesDocument_7;
    var xmlProcesses = capabilities.processOfferings.processes;

    xmlProcesses = xmlProcesses.where((p) => p.identifier.startsWith("py:"));

    for (var xmlProcess in xmlProcesses) {
      OgcDocument doc = await this.describeProcess(xmlProcess.identifier);
      OgcProcessDescription_16 xmlDescription = doc as OgcProcessDescription_16;
      print(xmlDescription.identifier);

      WpsProcess process = new WpsProcess(this, xmlDescription.identifier);

      var xmlInputs = xmlDescription.dataInput.dataInputs;
      for (OgcInputDescription_19 xmlInput in xmlInputs) {
        var datatype = inferDatatype(xmlInput.abstract, xmlInput.literalData.datatype);
        var name = xmlInput.identifier;
        //print("IN {$name} ${datatype}");

        WpsProcessParam param = new WpsProcessParam(name, datatype);
        process.inputs.add(param);
      }

      process.inputs.add(new WpsProcessParam("posn", WpsProcessParamDataType.position));
      process.inputs.add(new WpsProcessParam("box", WpsProcessParamDataType.bbox));

      var xmlOutputs = xmlDescription.processOutputs.outputData;
      for (var xmlOutput in xmlOutputs) {
        var name = xmlOutput.identifier;
        var datatype = inferDatatype(xmlOutput.abstract, xmlOutput.literalOutput.datatype);
        //print("OUT {$nam} ${dt}");
        WpsProcessParam param = new WpsProcessParam(name, datatype);
        process.outputs.add(param);
      }

      processes[xmlDescription.identifier] = process;
    }
  }

  Future<String> testConnection() async {
    OgcDocument capabilities = await getCapabilities();

    if (capabilities is! OgcCapabilitiesDocument_7) {
      RialtoBackend.error("GetCapabilities check: FAILED");
    }

    return new Future.value(null);
  }
}
