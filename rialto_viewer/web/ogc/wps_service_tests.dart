// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class WpsServiceTest {

    static void test(WpsService wps) {
        //OgcDocumentTests.test();
        //testCapabilities();
        //testDescribeHello();
        //testExecuteHello();
        //testDescribeViewshed();
        //testExecuteViewshed();
        testExecuteViewshed2(wps);
    }

    static void testCapabilities(WpsService wps) {
        wps.getCapabilities().then((OgcDocument doc) {
            assert(doc is OgcCapabilitiesDocument_7);
            //log(doc.dump(0));
            assert(doc.dump(0).contains("Identifier: groovy:wpshello"));
        });
    }

    static void testDescribeHello(WpsService wps) {
        wps.getProcessDescription("Hello").then((OgcDocument doc) {
            assert(doc is OgcProcessDescription_16);
            var desc = doc as OgcProcessDescription_16;
            //log(desc.dump(0));
            assert(desc.title == "GeoScriptHello");
            assert(desc.dataInput.dataInputs[0].identifier == "alpha");
            assert(desc.dataInput.dataInputs[1].identifier == "beta");
            assert(desc.processOutputs.outputData[0].identifier == "gamma");
        });
    }

    static void testExecuteHello(WpsService wps) {
        var inputs = {
            "alpha": "17",
            "beta": "11"
        };
        var outputs = ["gamma"];

        wps.executeProcess("Hello", inputs, outputs).then((OgcDocument doc) {
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

    static void testDescribeViewshed(WpsService wps) {
        wps.getProcessDescription("Viewshed").then((OgcDocument doc) {
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

    static void testExecuteViewshed(WpsService wps) {
        var inputs = {
            "pt1lon": "1.0",
            "pt1lat": "10",
            "pt2lon": "100.0",
            "pt2lat": "1000.0"
        };
        var outputs = ["resultlon"];

        wps.executeProcess("Viewshed", inputs, outputs).then((OgcDocument doc) {

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

    static void testExecuteViewshed2(WpsService wps) {
        var params = new List(3);
        params[0] = "Viewshed";
        params[1] = {
            "pt1lon": 2.0,
            "pt1lat": 20.0,
            "pt2lon": 200.0,
            "pt2lat": 2000.0
        };
        params[2] = ["resultlon"];

        wps.doWpsRequest(new WpsRequestData(WpsRequestData.EXECUTE_PROCESS, params)).then((id) {
            log("started: $id");
        });
    }
}

