// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

typedef Future<dynamic> ChainCommndFunction(dynamic);

class Commands {
  Hub _hub;

  Commands() : _hub = Hub.root;

  Future<Layer> addLayer(LayerData data) {
    return _hub.layerManager.doAddLayer(data);
  }

  Future colorizeLayers(ColorizerData data) {
    return _hub.layerManager.doColorizeLayers(data);
  }

  Future removeLayer(String layer) {
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

  Future loadScriptFromString(String yaml) {
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

  Future updateCamera(CameraData data) {
    return _hub.camera.doUpdateCamera(data);
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

  Future displayBbox(bool v) {
    _hub.displayBbox(v);
    return new Future(() {});
  }

  Future changeMode(ModeData data) {
    _hub.modeController.doChangeMode(data);
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

enum CameraViewMode { normalMode, worldviewMode, dataviewMode }

class CameraData {
  CameraViewMode viewMode;
  Cartographic3 eye; // cartographic
  Cartographic3 target; // cartographic
  Cartesian3 up; // cartesian
  double fov;
  CameraData(this.eye, this.target, this.up, this.fov)
      : viewMode = CameraViewMode.normalMode;
  CameraData.fromMode(this.viewMode);
}

class LayerData {
  String name;
  Map map;
  LayerData(String this.name, Map this.map);
}

enum ModeDataCodes { invalid, measurement, view, annotation, viewshed }

class ModeData {
  static final name = {
    ModeDataCodes.measurement: "measurement",
    ModeDataCodes.view: "view",
    ModeDataCodes.annotation: "annotation",
    ModeDataCodes.viewshed: "viewshed"
  };

  ModeDataCodes type;

  ModeData(ModeDataCodes this.type);
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
