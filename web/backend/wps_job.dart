// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend;

/// Everything about a WPS job
///
/// Includes things like timestamp, current status, outputs/results, and so on.
///
/// A [WpsJob] internally does it's own polling to keep its status up-to-date.
class WpsJob {
  RialtoBackend _backend;
  final WpsProcess process;
  final int id;
  Uri statusLocation;
  Uri proxyUri;
  OgcStatusCodes jobStatus; // from the server
  List<String> exceptionTexts;
  OgcExecuteResponseDocument_54 responseDocument;
  final DateTime _startTime;
  DateTime jobCreationTime; // from the server
  DateTime _timeoutTime;
  int _pollCount = 0;

  Map<String, dynamic> inputs = new Map<String, dynamic>();
  Map<String, dynamic> outputs = new Map<String, dynamic>();

  WpsJobResultHandler _successHandler;
  WpsJobResultHandler _errorHandler;
  WpsJobResultHandler _timeoutHandler;

  /// WpsJob constructor
  ///
  /// Users should not call this directly -- call [WpsJobManager.createJob] instead.
  WpsJob(WpsProcess this.process, int this.id, Map<String, dynamic> inputsx, {WpsJobResultHandler successHandler: null,
      WpsJobResultHandler errorHandler: null, WpsJobResultHandler timeoutHandler: null})
      : jobStatus = OgcStatusCodes.notYetSubmitted,
        _startTime = new DateTime.now(),
        _successHandler = successHandler,
        _errorHandler = errorHandler,
        _timeoutHandler = timeoutHandler {
    _backend = process.service.backend;

    inputs.addAll(inputsx);

    _timeoutTime = _startTime.add(WpsJobManager.pollingTimeout);
    _signalJobChange();

    if (_successHandler == null) {
      _successHandler = (WpsJob job) {
        RialtoBackend.log("WPS job ${job.process.name} succeeded");
        for (var key in job.outputs.keys) {
          if (key.startsWith("_")) continue;
          var value = job.outputs[key];
          RialtoBackend.log("  $key: $value");
        }
      };
    }

    if (_errorHandler == null) {
      _errorHandler = (WpsJob job) {
        RialtoBackend.log("FAILURE");
        assert(job.responseDocument != null || job.exceptionTexts != null);
        if (job.responseDocument != null) {
          RialtoBackend.log(job.responseDocument.dump(0));
        }
        if (job.exceptionTexts != null) {
          RialtoBackend.log(job.exceptionTexts);
        }
      };
    }

    if (_timeoutHandler == null) {
      _timeoutHandler = (WpsJob job) {
        RialtoBackend.error("wps request timed out!");
      };
    }
  }

  bool get _isActive => OgcStatus_55.isActive(jobStatus);
  bool get _hasFailed => OgcStatus_55.isFailure(jobStatus);
  bool get _hasSucceeded => OgcStatus_55.isSuccess(jobStatus);

  startPolling() => new Timer(WpsJobManager.pollingDelay, _poll);

  stopPolling() {
    if (jobStatus == OgcStatusCodes.timeout) {
      if (_timeoutHandler != null) {
        _timeoutHandler(this);
      }
    }

    if (_hasFailed) {
      if (_errorHandler != null) {
        _errorHandler(this);
      }
    } else {
      assert(_hasSucceeded);
      if (_successHandler != null) {
        for (var param in process.outputs) {
          var value = responseDocument.getProcessOutput(param.name);
          outputs[param.name] = value;
        }
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
      jobStatus = OgcStatusCodes.timeout;
      exceptionTexts = ["process timed out"];

      stopPolling();
      return;
    }

    assert(statusLocation != null);

    Utils.httpGet(statusLocation, proxyUri: proxyUri).then((Http.Response response) {
      var ogcDoc = OgcDocument.parseString(response.body);

      if (ogcDoc.isException) {
        jobStatus = OgcStatusCodes.systemFailure;
        exceptionTexts = ogcDoc.exceptionTexts;
        stopPolling();
        return;
      }

      if (ogcDoc is! OgcExecuteResponseDocument_54) {
        jobStatus = OgcStatusCodes.systemFailure;
        exceptionTexts = ["polled response neither exception report not response document"];
        stopPolling();
        return;
      }

      OgcExecuteResponseDocument_54 resp = ogcDoc;
      jobStatus = resp.status.code;
      responseDocument = resp;

      if (OgcStatus_55.isComplete(jobStatus)) {
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
    s += "Id: $id\n";
    s += "Status location: $statusLocation\n";
    s += "Start time: $_startTime\n";
    s += "Status: $jobStatus\n";

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
