// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend;

typedef dynamic WpsJobResultHandler(WpsJob job);

/// Manager of WPS operations
///
/// The (singleton) Rialto class has exactly one instance of this class. This manager
/// is repsonsible for keeping track of all WPS jobs, both completed and in progress.
class WpsJobManager {
  static final Duration pollingDelay = new Duration(seconds: 1);
  static final Duration pollingTimeout = new Duration(minutes: 1);

  RialtoBackend _backend;
  Map<int, WpsJob> map = new Map<int, WpsJob>();
  int _jobId = 0;

  WpsJobManager(RialtoBackend this._backend);

  int get numActive => map.values.where((j) => j._isActive).length;

  /// Execute a WPS process
  ///
  /// Returns the job object (even in the case of failures).
  ///
  Future<WpsJob> execute(WpsProcess process, Map<String, dynamic> inputs, {WpsJobResultHandler successHandler: null,
      WpsJobResultHandler errorHandler: null, WpsJobResultHandler timeoutHandler: null}) {
    var c = new Completer<WpsJob>();

    var job = new WpsJob(process, _jobId, inputs,
        successHandler: successHandler, errorHandler: errorHandler, timeoutHandler: timeoutHandler);
    _jobId++;
    map[job.id] = job;

    process.service.execute(job).then((ok) {
      if (ok) {
        job.startPolling();
      }
      c.complete(job);
    });

    return c.future;
  }

  // this function is used as the successHandler for executeProcess()
  Future loadLayers(WpsJob job) {
    OgcExecuteResponseDocument_54 ogcDoc = job.responseDocument;
    RialtoBackend.log("WPS job success");
    RialtoBackend.log(ogcDoc.dump(0));

    for (var key in job.outputs.keys) {
      RialtoBackend.log("$key: ${job.outputs[key]}");

      /*var layerName = "viewshed-${job.id}";
        Map layerOptions = {
        "type": "tms_imagery",
        "url": url,
        "gdal2Tiles": true,
        "maximumLevel": 12,
        //"alpha": 0.5
        };*/
    }

    return null; //_backend.commands.addLayer(layerName, layerOptions);
  }
}
