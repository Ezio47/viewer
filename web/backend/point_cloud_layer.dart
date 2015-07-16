// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend;

// TODO: this class should live in rialto.backend.private

class PointCloudLayer extends Layer {
  var _provider;
  int numPoints;
  List<String> dimensions;
  BboxShape _bboxShape;

  // supported in Options Map:
  //   isVisible [inherited]
  //   colorDimension  (string)
  //   colorRamp  (string)
  //   isBboxVisible  (bool)

  PointCloudLayer(RialtoBackend backend, String name, Map map) : super(backend, "pointcloud", name, map) {
    requireUrl();

    if (!map.containsKey("colorDimension")) {
      options["colorDimension"] = "Z";
    }

    if (!map.containsKey("colorRamp")) {
      options["colorRamp"] = "Spectral";
    }

    if (!map.containsKey("isBboxVisible")) {
      options["isBboxVisible"] = true;
    }
  }

  dynamic get provider => _provider;

  @override
  Future load() {
    Completer c = new Completer();

    backend.cesium
        .createTileProviderAsync(urlString, options["colorRamp"], options["colorDimension"], options["isVisible"])
        .then((provider) {
      _provider = provider;

      numPoints = backend.cesium.getNumPointsFromProvider(_provider);

      var xStats = backend.cesium.getStatsFromProvider(_provider, "X");
      var yStats = backend.cesium.getStatsFromProvider(_provider, "Y");
      var zStats = backend.cesium.getStatsFromProvider(_provider, "Z");

      bbox = new CartographicBbox.fromValues(xStats[0], yStats[0], zStats[0], xStats[2], yStats[2], zStats[2]);

      dimensions = backend.cesium.getDimensionNamesFromProvider(_provider);

      if (_bboxShape != null) {
        _bboxShape.remove();
      }
      if (options["isBboxVisible"] && bbox != null && bbox.isValid) {
        _bboxShape = new BboxShape(backend, bbox.minimum, bbox.maximum);
      }

      c.complete();
    });

    return c.future;
  }

  @override
  Future unload() {
    return new Future(() {
      backend.cesium.unloadTileProvider(_provider);
      if (_bboxShape != null) {
        _bboxShape.remove();
      }
    });
  }
}
