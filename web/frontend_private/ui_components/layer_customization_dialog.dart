// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

class LayerCustomizationDialog extends DialogVM {
  BetterListBoxVM _listbox;

  ListBoxVM _rampsListBox;
  ListBoxVM _dimsListBox;
  CheckBoxVM _visibilityButton;
  CheckBoxVM _bboxVisibilityButton;

  LayerCustomizationDialog(RialtoFrontend frontend, String id) : super(frontend, id) {
    _rampsListBox = new ListBoxVM(_frontend, "layerCustomizationDialog_colorRamps");
    _dimsListBox = new ListBoxVM(_frontend, "layerCustomizationDialog_colorDims");

    _visibilityButton = new CheckBoxVM(_frontend, "layerCustomizationDialog_visibility", true);
    _bboxVisibilityButton = new CheckBoxVM(_frontend, "layerCustomizationDialog_bboxVisibility", true);

    _trackState(_rampsListBox);
    _trackState(_dimsListBox);
    _trackState(_visibilityButton);
    _trackState(_bboxVisibilityButton);

    _listbox = new BetterListBoxVM(_frontend, "layerList2", _updateButtons);

    _updateButtons();
  }

  @override
  void _show() {
    _listbox.clear();

    for (var layer in _backend.layerManager.layers) {
      _listbox.add(layer);
    }

    _updateButtons();
  }

  @override
  void _hide() {
    Layer _target = _listbox.value;

    String ramp = _rampsListBox.getValue();

    String dim = _dimsListBox.getValue();

    if (ramp != null && dim != null) {
      _backend.commands.colorizeLayers(new ColorizerData(ramp, dim));
    }

    if (_target is VisibilityControl) {
      var t = (_target as VisibilityControl);
      t.visible = _visibilityButton.getValue();
    }
  }

  void _updateButtons([_ = null]) {
    Layer _target = _listbox.value;

    if (_target != null) {
      print("list selected ${_target.name}");
    }

    final bool colorizer = (_target is ColorizerControl);
    final bool visibility = (_target is VisibilityControl);
    final bool bboxVisibility = (_target is BboxVisibilityControl);

    if (colorizer) {
      var ramps = _backend.cesium.getColorRampNames();
      ramps.forEach((s) => _rampsListBox.add(s));
      _rampsListBox.setValue(ramps[0]);

      var dims = new Set<String>();
      if (_target is ColorizerControl) {
        dims.addAll((_target as PointCloudLayer).dimensions);
      }

      dims = dims.toList();
      dims.sort();

      dims.forEach((d) => _dimsListBox.add(d));
      _dimsListBox.setValue(dims[0]);

      _rampsListBox.disabled = false;
      _dimsListBox.disabled = false;
    } else {
      _rampsListBox.disabled = true;
      _dimsListBox.disabled = true;
    }

    if (visibility) {
      _visibilityButton.disabled = false;
      _visibilityButton.setValue((_target as VisibilityControl).visible);
    } else {
      _visibilityButton.disabled = true;
    }

    if (bboxVisibility) {
      _bboxVisibilityButton.disabled = false;
      _bboxVisibilityButton.setValue((_target as BboxVisibilityControl).bboxVisible);
    } else {
      _bboxVisibilityButton.disabled = true;
    }
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
      _selection = _layerToItemMap[layer];
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
