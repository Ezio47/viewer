// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

class LayerCustomizationDialog extends DialogVM {
  ListBoxVM _layerListBox;

  ListBoxVM _rampsListBox;
  ListBoxVM _dimsListBox;
  CheckBoxVM _visibilityButton;
  CheckBoxVM _bboxVisibilityButton;

  LayerCustomizationDialog(RialtoFrontend frontend, String id) : super(frontend, id) {
    _rampsListBox = new ListBoxVM(_frontend, "layerCustomizationDialog_colorRamps");
    _dimsListBox = new ListBoxVM(_frontend, "layerCustomizationDialog_colorDims");

    _visibilityButton = new CheckBoxVM(_frontend, "layerCustomizationDialog_visibility", true);
    _bboxVisibilityButton = new CheckBoxVM(_frontend, "layerCustomizationDialog_bboxVisibility", true);

    _layerListBox = new ListBoxVM(_frontend, "layerList", handler: _updateButtons);
  }

  @override
  void _show() {
    _layerListBox.clear();

    List<String> layerNames = new List<String>();
    List<Layer> layers = _backend.layerManager.layers;

    layers.forEach((layer) => layerNames.add(layer.name));
    layerNames.sort();

    for (var layer in layerNames) {
      _layerListBox.add(layer);
    }

    // set current selection to the first point cloud, if there is one
    var layer = layers.firstWhere((layer) => layer is PointCloudLayer, orElse: () => layers.first);
    _layerListBox.setValue(layer.name);

    _updateButtons();
  }

  @override
  void _hide() {
    String targetName = _layerListBox.getValue();
    Layer target = _backend.layerManager.lookupLayer(targetName);

    String colorRamp = _rampsListBox.getValue();
    String colorDimension = _dimsListBox.getValue();
    bool isVisible = _visibilityButton.getValue();
    bool isBboxVisible = _bboxVisibilityButton.getValue();

    var newOptions = {
      "colorRamp": colorRamp,
      "colorDimension": colorDimension,
      "isVisible": isVisible,
      "isBboxVisible": isBboxVisible
    };
    _backend.commands.reloadLayer(target, newOptions);
  }

  void _updateButtons([_ = null]) {
    final String layerName = _layerListBox.getValue();
    final Layer layer = _backend.layerManager.lookupLayer(layerName);
    final Map options = layer.options;

    _visibilityButton.disabled = false;
    _visibilityButton.setValue(options["isVisible"]);

    if (layer is PointCloudLayer) {
      var dims = new List<String>();
      dims.addAll(layer.dimensions);
      dims.sort();

      dims.forEach((d) => _dimsListBox.add(d));
      _dimsListBox.setValue(options["colorDimension"]);

      var provider = layer.provider;
      var ramps = _backend.cesium.getColorRampNamesFromProvider(provider);

      _rampsListBox.add("none");
      if (dims.contains("Red") && dims.contains("Green") && dims.contains("Blue")) {
        _rampsListBox.add("native");
      }
      ramps.forEach((s) => _rampsListBox.add(s));
      _rampsListBox.setValue(options["colorRamp"]);

      _rampsListBox.disabled = false;
      _dimsListBox.disabled = false;

      _bboxVisibilityButton.disabled = false;
      _bboxVisibilityButton.setValue(options["isBboxVisible"]);
    } else {
      _dimsListBox.disabled = true;
      _rampsListBox.disabled = true;
      _dimsListBox.clear();
      _rampsListBox.clear();

      _bboxVisibilityButton.disabled = true;
    }
  }
}
