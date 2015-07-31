// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend.private;

/// Unit tests for WPS operations
class WpsServiceTest {
  static void test(RialtoBackend backend) {
    new OgcDocumentTests(backend).test();
    testCapabilities(backend.wpsService);
    testDescribeSummation(backend.wpsService);
    testExecuteSummation(backend.wpsJobManager, backend.wpsService);
  }

  static void testCapabilities(WpsService wps) {
    wps.getCapabilities().then((OgcDocument doc) {
      assert(doc is OgcCapabilitiesDocument_7);
      //log(doc.dump(0));
      assert(doc.dump(0).contains("Identifier: groovy:wpssummationtest"));
    });
  }

  static void testDescribeSummation(WpsService wps) {
    wps.describeProcess("groovy:wpssummationtest").then((OgcDocument doc) {
      assert(doc is OgcProcessDescription_16);
      var desc = doc as OgcProcessDescription_16;
      //log(desc.dump(0));
      assert(desc.title == "SummationTest");
      assert(desc.dataInput.dataInputs[0].identifier == "alpha");
      assert(desc.dataInput.dataInputs[1].identifier == "beta");
      assert(desc.processOutputs.outputData[0].identifier == "gamma");
    });
  }

  static void testExecuteSummation(WpsJobManager jobManager, WpsService service) {
    var process = new WpsProcess(service, "groovy:wpssummationtest");

    var inputs = new Map<String, dynamic>();

    var alpha = new WpsProcessParam("alpha", WpsProcessParamDataType.integer, "");
    process.inputs.add(alpha);
    inputs["alpha"] = 17;

    var beta = new WpsProcessParam("beta", WpsProcessParamDataType.integer, "");
    process.inputs.add(beta);
    inputs["beta"] = 11;

    var gamma = new WpsProcessParam("gamma", WpsProcessParamDataType.integer, "");
    process.outputs.add(gamma);

    var successHandler = (WpsJob job) {
      var doc = job.responseDocument;
      assert(doc is OgcExecuteResponseDocument_54);
      OgcExecuteResponseDocument_54 resp = doc;
      var status = resp.status.processSucceeded;
      assert(status != null);
      OgcDataType_46 datatype = resp.processOutputs.outputDataList[0].data;
      OgcLiteralData_48 literalData = datatype.literalData;
      //log(literalData.dump(0));
      assert(literalData.value == "28.0");
    };

    jobManager.execute(process, inputs, successHandler: successHandler);
  }
}
