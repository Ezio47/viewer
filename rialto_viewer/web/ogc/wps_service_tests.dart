// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class WpsServiceTest {

    static void test(WpsService wps) {
        OgcDocumentTests.test();
        testCapabilities(wps);
        testDescribeSummation(wps);
        testExecuteSummation(wps);
        testExecuteSleep(wps, 60.0);
        testExecuteSleep(wps, 10.0);
        testExecuteSleep(wps, 20.0);
    }

    static void testCapabilities(WpsService wps) {
        wps.doOwsGetCapabilities().then((OgcDocument doc) {
            assert(doc is OgcCapabilitiesDocument_7);
            //log(doc.dump(0));
            assert(doc.dump(0).contains("Identifier: groovy:wpssummationtest"));
        });
    }

    static void testDescribeSummation(WpsService wps) {
        wps.doWpsDescribeProcess("groovy:wpssummationtest").then((OgcDocument doc) {
            assert(doc is OgcProcessDescription_16);
            var desc = doc as OgcProcessDescription_16;
            //log(desc.dump(0));
            assert(desc.title == "SummationTest");
            assert(desc.dataInput.dataInputs[0].identifier == "alpha");
            assert(desc.dataInput.dataInputs[1].identifier == "beta");
            assert(desc.processOutputs.outputData[0].identifier == "gamma");
        });
    }

    static void testExecuteSummation(WpsService wps) {
        var inputs = {
            "alpha": "17",
            "beta": "11"
        };
        var outputs = ["gamma"];

        var data = new WpsExecuteProcessData(["groovy:wpssummationtest", inputs, outputs]);

        var successHandler = (WpsJob job) {
            var doc = job.responseDocument;
            assert(doc is OgcExecuteResponseDocument_54);
            OgcExecuteResponseDocument_54 resp = doc;
            var status = resp.status.processSucceeded;
            assert(status != null);
            OgcDataType_46 datatype = resp.processOutputs.outputData[0].data;
            OgcLiteralData_48 literalData = datatype.literalData;
            //log(literalData.dump(0));
            assert(literalData.value == "28.0");
        };

        wps.doWpsExecuteProcess(data, successHandler: successHandler);
    }

    static void testExecuteSleep(WpsService wps, double duration) {
        var alpha = 17.0;
        var beta = 11.0;

        var inputs = {
            "alpha": alpha.toString(),
            "beta": beta.toString(),
            "duration": duration.toString()
        };
        var outputs = ["gamma"];

        var data = new WpsExecuteProcessData(["groovy:wpssleeptest", inputs, outputs]);

        var successHandler = (WpsJob job) {
            var doc = job.responseDocument;
            assert(doc is OgcExecuteResponseDocument_54);
            OgcExecuteResponseDocument_54 resp = doc;
            var status = resp.status.processSucceeded;
            assert(status != null);
            OgcDataType_46 datatype = resp.processOutputs.outputData[0].data;
            OgcLiteralData_48 literalData = datatype.literalData;
            //log(literalData.dump(0));
            assert(double.parse(literalData.value) == (alpha + beta + duration));
        };

        wps.doWpsExecuteProcess(data, successHandler: successHandler);
    }
}
