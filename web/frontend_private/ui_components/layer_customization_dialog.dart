// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

class LayerCustomizationDialog extends DialogVM {
  BetterListBoxVM _layerListBox;

  ListBoxVM _rampsListBox;
  ListBoxVM _dimsListBox;
  CheckBoxVM _visibilityButton;
  CheckBoxVM _bboxVisibilityButton;

  LayerCustomizationDialog(RialtoFrontend frontend, String id) : super(frontend, id) {
    _rampsListBox = new ListBoxVM(_frontend, "layerCustomizationDialog_colorRamps");
    _dimsListBox = new ListBoxVM(_frontend, "layerCustomizationDialog_colorDims");

    _visibilityButton = new CheckBoxVM(_frontend, "layerCustomizationDialog_visibility", true);
    _bboxVisibilityButton = new CheckBoxVM(_frontend, "layerCustomizationDialog_bboxVisibility", true);

    _layerListBox = new BetterListBoxVM(_frontend, "layerList2", _updateButtons);

    //  _updateButtons();
  }

  @override
  void _show() {
    _layerListBox.clear();

    for (var layer in _backend.layerManager.layers) {
      _layerListBox.add(layer);
    }

    _layerListBox.value = _backend.layerManager.layers[0];

    _updateButtons();
  }

  @override
  void _hide() {
    Layer _target = _layerListBox.value;

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
    _backend.commands.reloadLayer(_target, newOptions);
  }

  void _updateButtons([_ = null]) {
    Layer _target = _layerListBox.value;

    _dimsListBox.clear();
    _rampsListBox.clear();

    if (_target is PointCloudLayer) {
      var dims = new List<String>();
      dims.addAll(_target.dimensions);
      dims.sort();

      dims.forEach((d) => _dimsListBox.add(d));
      _dimsListBox.setValue("Z");

      var provider = _target.provider;
      var ramps = _backend.cesium.getColorRampNamesFromProvider(provider);

      _rampsListBox.add("none");
      if (dims.contains("Red") && dims.contains("Green") && dims.contains("Blue")) {
        _rampsListBox.add("native");
      }
      ramps.forEach((s) => _rampsListBox.add(s));
      _rampsListBox.setValue("none");

      _rampsListBox.disabled = false;
      _dimsListBox.disabled = false;
    }

    _bboxVisibilityButton.setValue(_target.options["isBboxVisible"]);
    _visibilityButton.setValue(_target.options["isVisible"]);
  }
}

class BetterListBoxItem {
  final Layer layer;
  DivElement element;

  BetterListBoxItem(Layer this.layer) {
    var span = new SpanElement();
    span.text = layer.name;

    var label = new LabelElement();
    label.children.add(span);

    var li = new LIElement();
    li.children.add(label);

    var div = new DivElement();
    div.children.add(li);

    element = div;
  }
}

class BetterListBoxVM extends ViewModel {
  List<BetterListBoxItem> _itemsList = new List<BetterListBoxItem>();
  UListElement _ulElement;
  Map<DivElement, BetterListBoxItem> _divToItemMap = new Map<DivElement, BetterListBoxItem>();
  Map<Layer, BetterListBoxItem> _layerToItemMap = new Map<Layer, BetterListBoxItem>();
  BetterListBoxItem _selection;
  Function _onSelection;

  BetterListBoxVM(RialtoFrontend frontend, String id, Function this._onSelection) : super(frontend, id) {
    _ulElement = _element;
    _ulElement.children.clear();
  }

  void _selectHandler(Event e) {
    Element element = e.currentTarget;
    if (element == null) return;

    BetterListBoxItem item = _divToItemMap[element];
    _selectItemAction(item);
  }

  void _selectItemAction(BetterListBoxItem item) {
    if (item == _selection) {
      // do nothing
      return;
    }

    if (_selection != null) {
      //log("${_selection.layer.name} unselected");
      _selection.element.attributes["class"] = "";
    }

    _selection = item;
    //log("${_selection.layer.name} selected");

    _selection.element.attributes["class"] = "uk-text-success";

    _onSelection(_selection.layer);
  }

  Layer get value {
    if (_selection == null) {
      return null;
    }
    return _selection.layer;
  }

  set value(Layer layer) {
    if (layer == null) {
      _selection = null;
      return;
    }

    if (_layerToItemMap.containsKey(layer)) {
      var item = _layerToItemMap[layer];
      _selectItemAction(item);
      return;
    }

    throw new ArgumentError("bad layer name");
  }

  void add(Layer layer) {
    var item = new BetterListBoxItem(layer);
    _itemsList.add(item);
    _ulElement.children.add(item.element);
    _divToItemMap[item.element] = item;
    _layerToItemMap[layer] = item;

    item.element.onClick.listen(_selectHandler);
  }

  void remove(Layer layer) {
    var item = _layerToItemMap[layer];

    _itemsList.remove(item);
    _layerToItemMap.remove(item.layer);
    _divToItemMap.remove(item.element);

    _ulElement.children.remove(item.element);
  }

  void clear() {
    _itemsList.clear();
    _divToItemMap.clear();
    _ulElement.children.clear();
    _selection = null;
  }
}
