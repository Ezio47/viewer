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


class CommandChainer {
    Function _f;

    CommandChainer(Function this._f) {

    }

}
