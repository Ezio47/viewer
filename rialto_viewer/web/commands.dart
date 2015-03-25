// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

typedef Future<dynamic> ChainCommndFunction(dynamic);

class Commands {
  Hub _hub;

  Commands() : _hub = Hub.root;

  void createViewshedCircle() {
    _hub.cesium.drawCircle(
        (longitude, latitude, height, radius) => _hub.viewshedCircles.add([longitude, latitude, height, radius]));
  }

  void computeViewshed() {
    for (var v in _hub.viewshedCircles) {
      double obsLon = v[0];
      double obsLat = v[1];
      //double obsHeight = v[2];
      var radius = v[3];

      Viewshedder.callWps(obsLon, obsLat, radius);
    }
  }

  void computeLinearMeasurement() {
      _hub.cesium.drawPolyline((positions) {
          log("Length of ...");// + positions);
          var dist = _hub.computeLength(positions);
          var mi = dist / 1609.34;
          window.alert("Distance: ${dist.toStringAsFixed(1)} meters (${mi.toStringAsFixed(1)} miles)");
      });
  }

  void computeAreaMeasurement() {
      _hub.cesium.drawPolygon((positions) {
          log("Area of ...");// + positions);
          var area = _hub.computeArea(positions);
          window.alert("Area: ${area.toStringAsFixed(1)} m^2");
      });
  }

  void dropPin() {
      _hub.cesium.drawMarker((position) {
          log("Pin...");// + position);
      });
  }

  void drawExtent() {
      _hub.cesium.drawExtent((n, s, e,w) {
          log("Extent: " + n.toString() + " " + s.toString() + " " + e.toString() + " " + w.toString());
      });
  }

  Future<Layer> addLayer(LayerData data) {
    return _hub.layerManager.doAddLayer(data);
  }

  Future colorizeLayers(ColorizerData data) {
    return _hub.layerManager.doColorizeLayers(data);
  }

  Future removeLayer(Layer layer) {
    return _hub.layerManager.doRemoveLayer(layer);
  }

  Future removeAllLayers() {
    return _hub.layerManager.doRemoveAllLayers();
  }

  Future loadScriptFromUrl(Uri url) {
    var s = new ConfigScript();
    var f = s.loadFromUrl(url);
    return f;
  }

  Future loadScriptFromStringAsync(String yaml) {
    var s = new ConfigScript();
    var f = s.loadFromString(yaml);
    return f;
  }

  Future wpsExecuteProcess(WpsExecuteProcessData data) {
    return _hub.wps.doWpsExecuteProcess(data,
        successHandler: data.successHandler,
        errorHandler: data.errorHandler,
        timeoutHandler: data.timeoutHandler);
  }

  Future wpsDescribeProcess(String processName) {
    return _hub.wps.doWpsDescribeProcess(processName);
  }

  Future owsGetCapabilities() {
    return _hub.wps.doOwsGetCapabilities();
  }

  Future zoomTo(Cartographic3 eyePosition, Cartographic3 targetPosition, Cartesian3 upDirection, double fov) {
    return _hub.zoomTo(eyePosition, targetPosition, upDirection, fov);
  }

  Future zoomToLayer(Layer layer) {
    return _hub.zoomToLayer(layer);
  }

  Future zoomToWorld() {
    return _hub.zoomToWorld();
  }

  Future setViewMode(ViewModeData mode) {
    _hub.cesium.setViewMode(mode.mode.index);
    return new Future(() {});
  }

  Future displayLayerData(DisplayLayerData data) {
    assert(data.layer != null);
    if (data.layer is VisibilityControl) {
      (data.layer as VisibilityControl).visible = data.visible;
    }
    return new Future(() {});
  }

  // given a list of things, run a function F against each one, in order
  // and with an explicit wait between each one
  //
  // and return a Future with the list of the results from each F
  static Future<List<dynamic>> run(
      ChainCommndFunction f, List<dynamic> inputs) {
    List<dynamic> outputs = [];
    var c = new Completer();

    _executeNextCommand(f, inputs, 0, outputs, c).then((_) {});

    return c.future;
  }

  static Future _executeNextCommand(ChainCommndFunction f, List<dynamic> inputs,
      int index, List<dynamic> outputs, Completer c) {
    dynamic input = inputs[index];

    f(input).then((dynamic result) {
      outputs.add(result);

      if (index + 1 != inputs.length) {
        _executeNextCommand(f, inputs, index + 1, outputs, c);
      } else {
        c.complete(outputs);
        return;
      }
    });

    return c.future;
  }
}

class DisplayLayerData {
  Layer layer;
  bool visible;
  DisplayLayerData(this.layer, this.visible);
}

class LayerData {
  String name;
  Map map;
  LayerData(String this.name, Map this.map);
}

class WpsExecuteProcessData {
  final List<Object> parameters;
  final WpsJobResultHandler successHandler;
  final WpsJobResultHandler errorHandler;
  final WpsJobResultHandler timeoutHandler;

  WpsExecuteProcessData(List<Object> this.parameters,
      {WpsJobResultHandler successHandler: null,
      WpsJobResultHandler errorHandler: null,
      WpsJobResultHandler timeoutHandler: null})
      : this.successHandler = successHandler,
        this.errorHandler = errorHandler,
        this.timeoutHandler = timeoutHandler;
}

class ColorizerData {
  String ramp;
  String dimension;
  ColorizerData(String this.ramp, String this.dimension);
}

enum ViewModeCode { mode2D, mode25D, mode3D }

class ViewModeData {
  final ViewModeCode mode;

  ViewModeData(ViewModeCode this.mode);

  static Map name = {
    ViewModeCode.mode2D: "2D",
    ViewModeCode.mode25D: "2.5D",
    ViewModeCode.mode3D: "3D"
  };
}
