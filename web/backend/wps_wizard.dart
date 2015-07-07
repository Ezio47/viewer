// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend;

class WpsWizard {
    RialtoBackend _backend;
    dynamic _frontend;

    WpsWizard(dynamic this._frontend, RialtoBackend this._backend);

    void run(String processName) {

        WpsProcess process = _backend.wps.processes[processName];
        print("running wizard ${process.name}");

        var inputs = new Map<String, dynamic>();
        for (WpsProcessParam param in process.inputs) {
            switch (param.datatype) {
                case WpsProcessParamDataType.double:
                    inputs[param.name] = wizardGetDouble(param.name);
                    break;
                case WpsProcessParamDataType.integer:
                    inputs[param.name] = wizardGetInteger(param.name);
                    break;
                case WpsProcessParamDataType.string:
                    inputs[param.name] = wizardGetString(param.name);
                    break;
                default:
                    RialtoBackend.error("invalid wps datatype");
            }
        }

        var yes = (WpsJob job, Map<String, dynamic> results) {
            OgcExecuteResponseDocument_54 ogcDoc = job.responseDocument;
            RialtoBackend.log("SUCCESS: $results");
        };

        var no = (WpsJob job) {
            RialtoBackend.log("FAILURE");
            assert(job.responseDocument != null || job.exceptionTexts != null);
            if (job.responseDocument != null) {
                RialtoBackend.log(job.responseDocument.dump(0));
            }
            if (job.exceptionTexts != null) {
                RialtoBackend.log(job.exceptionTexts);
            }
        };

        var time = (WpsJob job) {
            RialtoBackend.error("wps request timed out!");
        };

        _backend.commands.wpsExecuteProcess(process, inputs, yes, no, time);
    }

    String wizardGetDouble(String name) {
        return "1.1";
    }

    String wizardGetInteger(String name) {
        return "22";
    }

    String wizardGetString(String name) {
        return "33";
    }
}
