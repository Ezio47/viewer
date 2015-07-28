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

  Future<bool> execute(WpsJob job) {
    var c = new Completer<bool>();

    var process = job.process;
    var inputs = job.inputs;

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

    //RialtoBackend.log(parms);
    _sendKvpServerRequest("Execute", parms).then((OgcDocument ogcDoc) {
      if (ogcDoc == null) {
        RialtoBackend.error("Error parsing WPS process execution response document");
        job.jobStatus = OgcStatusCodes.systemFailure;
        c.complete(false);
        return;
      }

      if (ogcDoc is OgcExceptionReportDocument) {
        job.jobStatus = OgcStatusCodes.failed;
        job.exceptionTexts = ogcDoc.exceptionTexts;
        c.complete(false);
        return;
      }

      if (ogcDoc is! OgcExecuteResponseDocument_54) {
        RialtoBackend.error("Error parsing WPS process execution response document");
        job.jobStatus = OgcStatusCodes.failed;
        c.complete(false);
        return;
      }

      var resp = ogcDoc as OgcExecuteResponseDocument_54;

      job.statusLocation = Uri.parse(resp.statusLocation);
      job.proxyUri = proxyUri;
      job.jobCreationTime = DateTime.parse(resp.status.creationTime);
      job.jobStatus = resp.status.code;

      c.complete(true);
    });

    return c.future;
  }

  /// Issues a "describe process" request to the WPS server
  ///
  /// Returns the response document
  Future<OgcDocument> describeProcess(String processName) {
    return _getProcessDescriptionWork(processName);
  }

  static String _extractFieldFromDescription(String description, String field) {
    if (description == null) return null;
    var lines = description.split('#');
    lines = lines.map((s) => s.trim()).toList();
    for (String line in lines) {
      int idx = line.indexOf(field + ':');
      if (idx != -1) {
        var value = line.substring((field + ':').length);
        value = value.trim();
        return value;
      }
    }
    return null;
  }

  static WpsProcessParamDataType inferDatatype(String abstract, String datatype_notused) {
    var dt = _extractFieldFromDescription(abstract, "datatype");
    assert(dt != null);

    if (dt.startsWith("enum:")) {
      return WpsProcessParamDataType.string;
    }

    switch (dt) {
      case "string":
        return WpsProcessParamDataType.string;
      case "int":
        return WpsProcessParamDataType.integer;
      case "double":
        return WpsProcessParamDataType.double;
      case "geo_pos_2d":
        return WpsProcessParamDataType.position;
      case "geo_box_2d":
        return WpsProcessParamDataType.box;
      default:
        RialtoBackend.error("unknown passed datatype: $dt");
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

      WpsProcess process = new WpsProcess(this, xmlDescription.identifier);

      var xmlInputs = xmlDescription.dataInput.dataInputs;
      for (OgcInputDescription_19 xmlInput in xmlInputs) {
        var datatype = inferDatatype(xmlInput.abstract, xmlInput.literalData.datatype);
        var name = xmlInput.identifier;
        //print("IN {$name} ${datatype}");

        WpsProcessParam param = new WpsProcessParam(name, datatype, xmlInput.abstract);
        process.inputs.add(param);
      }

      var xmlOutputs = xmlDescription.processOutputs.outputData;
      for (var xmlOutput in xmlOutputs) {
        var name = xmlOutput.identifier;

        ////////var datatype = inferDatatype(xmlOutput.abstract, xmlOutput.literalOutput.datatype);
        var datatype = WpsProcessParamDataType.string;

        WpsProcessParam param = new WpsProcessParam(name, datatype, xmlOutput.abstract);
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

    var numProcesses = (capabilities as OgcCapabilitiesDocument_7).processOfferings.processes.length;
    return new Future.value("server providing $numProcesses processes");
  }
}
