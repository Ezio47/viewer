// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class WpsJobManager {
    static final Duration pollingDelay = new Duration(seconds: 1);
    static final Duration pollingTimeout = new Duration(minutes: 5);

    Hub _hub;
    Map<int, WpsJob> map = new Map<int, WpsJob>();
    int _jobId = 0;

    WpsJobManager() : _hub = Hub.root;

    WpsJob createStatusObject(WpsService service) {
        var obj = new WpsJob(service, newJobId);
        add(obj);
        return obj;
    }

    void add(WpsJob status) {
        map[status.id] = status;
    }

    int get newJobId => _jobId++;

    int get numActive => map.values.where((j) => j.isActive).length;
}


typedef Future WpsJobResultFunction(WpsJob);

class WpsJob {
    Hub _hub = Hub.root;
    final WpsService service;
    final int id;
    Uri statusLocation;
    DateTime processCreationTime;
    Uri proxyUri;
    int code; // from OgcStatus_55 enums
    List<String> exceptionTexts;
    OgcExecuteResponseDocument_54 responseDocument;
    final DateTime _startTime;
    DateTime _timeoutTime;

    WpsJobResultFunction onTimeout;
    WpsJobResultFunction onSuccess;
    WpsJobResultFunction onFailure;

    WpsJob(WpsService this.service, int this.id)
            : code = OgcStatus_55.STATUS_NOTYETSUBMITTED,
              _startTime = new DateTime.now() {
        _timeoutTime = _startTime.add(WpsJobManager.pollingTimeout);
        _signalJobChange();

        new Timer(WpsJobManager.pollingDelay, _poll);
    }

    bool get isActive => OgcStatus_55.isActive(code);
    bool get isComplete => OgcStatus_55.isComplete(code);

    void _poll() {

        log("polling...");

        var now = new DateTime.now();
        if (now.isAfter(_timeoutTime)) {
            code = OgcStatus_55.STATUS_SYSTEMFAILURE;
            exceptionTexts = ["process timed out"];

            _signalJobChange();

            if (onTimeout != null) {
                onTimeout(this);
            }
            return;

        }

        Comms.httpGet(statusLocation, proxyUri: proxyUri).then((Http.Response response) {
            var ogcDoc = OgcDocument.parseString(response.body);
            //log(ogcDoc.dump(0));

            if (ogcDoc.isException) {
                code = OgcStatus_55.STATUS_SYSTEMFAILURE;
                exceptionTexts = ogcDoc.exceptionTexts;
                _signalJobChange();

                if (onFailure != null) {
                    onFailure(this);
                }
                return;
            }

            if (ogcDoc is! OgcExecuteResponseDocument_54) {
                code = OgcStatus_55.STATUS_SYSTEMFAILURE;
                exceptionTexts = ["polled response neither exception report not response document"];
                _signalJobChange();

                if (onFailure != null) {
                    onFailure(this);
                }
                return;
            }

            OgcExecuteResponseDocument_54 resp = ogcDoc;
            code = resp.status.code;
            responseDocument = resp;

            if (OgcStatus_55.isComplete(code)) {
                log("done!");
                _signalJobChange();

                if (onSuccess != null) {
                    onSuccess(this);
                }
                return;
            }

            log("requeueing!");
            new Timer(WpsJobManager.pollingDelay, _poll);
        });
    }

    void _signalJobChange() => _hub.events.WpsJobUpdate.fire(new WpsJobUpdateData(id));
}
