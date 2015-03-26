// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


typedef dynamic WpsJobResultHandler(WpsJob job);


/// Manager of WPS operations
///
/// The (singleton) Rialto class has exactly one instance of this class. This manager
/// is repsonsible for keeping track of all WPS jobs, both completed and in progress.
class WpsJobManager {
    static final Duration pollingDelay = new Duration(seconds: 2);
    static final Duration pollingTimeout = new Duration(minutes: 5);

    RialtoBackend _backend;
    Map<int, WpsJob> map = new Map<int, WpsJob>();
    int _jobId = 0;

    WpsJobManager(RialtoBackend this._backend);

    /// Start a WPS job
    ///
    /// The job will be tracked by this manager class.
    ///
    /// Use this function instead of calling the WpsJob ctor directly.
    WpsJob createJob(WpsService service, {WpsJobResultHandler successHandler: null, WpsJobResultHandler errorHandler:
            null, WpsJobResultHandler timeoutHandler: null}) {
        var obj = new WpsJob(
                _backend,
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


/// Everything about a WPS job
///
/// Includes things like timestamp, current status, outputs/results, and so on.
///
/// A [WpsJob] internally does it's own polling to keep its status up-to-date.
class WpsJob {
    RialtoBackend _backend;
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

    /// WpsJob constructor
    ///
    /// Users should nto call this directly -- call [WpsJobManager.createJob] instead.
    WpsJob(RialtoBackend this._backend, WpsService this.service, int this.id, {WpsJobResultHandler successHandler: null,
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
        RialtoBackend.log("poll #$_pollCount, $secs seconds elapsed");

        var now = new DateTime.now();
        if (now.isAfter(_timeoutTime)) {
            code = OgcStatusCodes.timeout;
            exceptionTexts = ["process timed out"];

            stopPolling();
            return;
        }

        assert(statusLocation != null);

        Utils.httpGet(statusLocation, proxyUri: proxyUri).then((Http.Response response) {
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
                //Hub.log("done!");

                stopPolling();
                return;
            }

            ++_pollCount;
            new Timer(WpsJobManager.pollingDelay, _poll);
        });
    }

    void _signalJobChange() => _backend.events.WpsJobUpdate.fire(new WpsJobUpdateData(id));

    String dump() {
        String s = "";
        s += service.dump();
        s += "Id: $id\n";
        s += "Status location: $statusLocation\n";
        s += "Creation time: $processCreationTime\n";
        s += "Status: $code\n";

        s += "Exception texts: ";
        if (exceptionTexts != null && exceptionTexts.length > 0) {
            s += "\n";
            exceptionTexts.forEach((t) => s += "  $t\n");
        } else {
            s += "(none)\n";
        }

        s += "Response document: ";
        if (responseDocument != null) {
            s += "\n";
            s += responseDocument.dump(2);
        } else {
            s += "(none)\n";
        }

        return s;
    }
}
