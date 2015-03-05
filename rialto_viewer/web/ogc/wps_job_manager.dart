// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


typedef dynamic WpsJobResultHandler(WpsJob job);


class WpsJobManager {
    static final Duration pollingDelay = new Duration(seconds: 2);
    static final Duration pollingTimeout = new Duration(minutes: 5);

    Hub _hub;
    Map<int, WpsJob> map = new Map<int, WpsJob>();
    int _jobId = 0;

    WpsJobManager() : _hub = Hub.root;

    WpsJob createStatusObject(WpsService service, {WpsJobResultHandler successHandler: null,
            WpsJobResultHandler errorHandler: null, WpsJobResultHandler timeoutHandler: null}) {
        var obj = new WpsJob(
                service,
                newJobId,
                successHandler: successHandler,
                errorHandler: errorHandler,
                timeoutHandler: timeoutHandler);
        add(obj);
        return obj;
    }

    void add(WpsJob status) {
        map[status.id] = status;
    }

    int get newJobId => _jobId++;

    int get numActive => map.values.where((j) => j.isActive).length;
}


class WpsJob {
    Hub _hub = Hub.root;
    final WpsService service;
    final int id;
    Uri statusLocation;
    DateTime processCreationTime;
    Uri proxyUri;
    OgcStatusCodes code;
    List<String> exceptionTexts;
    OgcExecuteResponseDocument_54 responseDocument;
    final DateTime _startTime;
    DateTime _timeoutTime;
    int _pollCount = 0;

    final WpsJobResultHandler _successHandler;
    final WpsJobResultHandler _errorHandler;
    final WpsJobResultHandler _timeoutHandler;

    WpsJob(WpsService this.service, int this.id, {WpsJobResultHandler successHandler: null,
            WpsJobResultHandler errorHandler: null, WpsJobResultHandler timeoutHandler: null})
            : code = OgcStatusCodes.notYetSubmitted,
              _startTime = new DateTime.now(),
              _successHandler = successHandler,
              _errorHandler = errorHandler,
              _timeoutHandler = timeoutHandler {

        _timeoutTime = _startTime.add(WpsJobManager.pollingTimeout);
        _signalJobChange();
    }

    bool get isActive => OgcStatus_55.isActive(code);
    bool get isComplete => OgcStatus_55.isComplete(code);
    bool get isFailure => OgcStatus_55.isFailure(code);
    bool get isSuccess => OgcStatus_55.isSuccess(code);

    startPolling() => new Timer(WpsJobManager.pollingDelay, _poll);

    stopPolling() {
        if (code == OgcStatusCodes.timeout) {
            if (_timeoutHandler != null) {
                _timeoutHandler(this);
            }
        }

        if (isFailure) {
            if (_errorHandler != null) {
                _errorHandler(this);
            }
        } else {
            assert(isSuccess);
            if (_successHandler != null) {
                _successHandler(this);
            }
        }

        _signalJobChange();
    }


    void _poll() {

        var secs = new DateTime.now().difference(_startTime).inSeconds;
        log("poll #$_pollCount, $secs seconds elapsed");

        var now = new DateTime.now();
        if (now.isAfter(_timeoutTime)) {
            code = OgcStatusCodes.timeout;
            exceptionTexts = ["process timed out"];

            stopPolling();
            return;
        }

        assert(statusLocation != null);

        Comms.httpGet(statusLocation, proxyUri: proxyUri).then((Http.Response response) {
            var ogcDoc = OgcDocument.parseString(response.body);
            //log(ogcDoc.dump(0));

            if (ogcDoc.isException) {
                code = OgcStatusCodes.systemFailure;
                exceptionTexts = ogcDoc.exceptionTexts;

                stopPolling();
                return;
            }

            if (ogcDoc is! OgcExecuteResponseDocument_54) {
                code = OgcStatusCodes.systemFailure;
                exceptionTexts = ["polled response neither exception report not response document"];

                stopPolling();
                return;
            }

            OgcExecuteResponseDocument_54 resp = ogcDoc;
            code = resp.status.code;
            responseDocument = resp;

            if (OgcStatus_55.isComplete(code)) {
                log("done!");

                stopPolling();
                return;
            }

            ++_pollCount;
            new Timer(WpsJobManager.pollingDelay, _poll);
        });
    }

    void _signalJobChange() => _hub.events.WpsJobUpdate.fire(new WpsJobUpdateData(id));
}
