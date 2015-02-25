// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

typedef Future<dynamic> ChainCommndFunction(dynamic);

class Commands {
    Hub _hub;

    Commands() :
        _hub = Hub.root;

    Future<Layer> addLayer(LayerData data) {
        return _hub.layerManager.doAddLayer(data);
    }

    Future colorizeLayers(ColorizeLayersData data) {
        return _hub.layerManager.doColorizeLayers(data);
    }

    Future removeLayer(String layer) {
        return _hub.layerManager.doRemoveLayer(layer);
    }

    Future removeAllLayers() {
        return _hub.layerManager.doRemoveAllLayers();
    }

    Future loadScript(String url) {
        var s = new ConfigScript(url);
        var f = s.run();
        return f;
    }

    Future wpsRequest(WpsRequestData data) {
        return _hub.wps.doWpsRequest(data);
    }

    Future updateCamera(CameraData data) {
        return _hub.camera.doUpdateCamera(data);
    }

    Future setViewMode(ViewModeData mode) {
        _hub.cesium.setViewMode(mode.mode);
        return new Future((){});
    }

    Future displayLayerData(DisplayLayerData data) {
        assert(data.layer != null);
        data.layer.visible = data.visible;
        return new Future((){});
    }

    Future displayBbox(bool v) {
        _hub.displayBbox(v);
        return new Future((){});
    }

    Future changeMode(ModeData data) {
        _hub.modeController.doChangeMode(data);
        return new Future((){});
    }

    // given a list of things, run a function F against each one, in order
    // and with an explicit wait between each one
    //
    // and return a Future with the list of the results from each F
    static Future<List<dynamic>> run(ChainCommndFunction f, List<dynamic> inputs) {

        List<dynamic> outputs = [];
        var c = new Completer();

        _executeNextCommand(f, inputs, 0, outputs, c).then((_) {

        });

        return c.future;
    }

    static Future _executeNextCommand(ChainCommndFunction f, List<dynamic> inputs, int index, List<dynamic> outputs, Completer c) {

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


class CameraData {
    static const int NORMAL_MODE = 0;
    static const int WORLDVIEW_MODE = 1;
    static const int DATAVIEW_MODE = 2;
    int viewMode;
    Cartographic3 eye; // cartographic
    Cartographic3 target; // cartographic
    Cartesian3 up; // cartesian
    double fov;
    CameraData(this.eye, this.target, this.up, this.fov) : viewMode=NORMAL_MODE;
    CameraData.fromMode(this.viewMode);
}


class LayerData {
    String name;
    Map map;
    LayerData(String this.name, Map this.map);
}


class ModeData {
    static const int INVALID = 0;
    static const int MEASUREMENT = 1;
    static const int VIEW = 2;
    static const int ANNOTATION = 4;
    static const int VIEWSHED = 5;
    static final name = {
        MEASUREMENT: "measurement",
        VIEW: "view",
        ANNOTATION: "annotation",
        VIEWSHED: "viewshed"
    };

    int type;

    ModeData(int this.type);
}


class WpsRequestData {
    static const int INVALID = 0;
    static const int VIEWSHED = 1;
    static final name = {
        VIEWSHED: "viewshed"
    };

    final int type;
    final List<Object> params;

    WpsRequestData(int this.type, List<Object> this.params);
}


class ColorizeLayersData {
    String ramp;
    String dimension;
    ColorizeLayersData(String this.ramp, String this.dimension);
}


class ViewModeData {
    static const int MODE_2D = 0;
    static const int MODE_25D = 1;
    static const int MODE_3D = 2;

    final int mode;

    ViewModeData(int this.mode);

    static String name(int m) {
        if (m == ViewModeData.MODE_2D) return "2D";
        if (m == ViewModeData.MODE_25D) return "2.5D";
        if (m == ViewModeData.MODE_3D) return "3D";
        throw new ArgumentError("bad view mode value");
    }
}

