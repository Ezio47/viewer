// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class LayerManagerDialog extends DialogVM {
    BetterListBoxVM _listbox;

    ButtonVM _addButton;
    ButtonVM _removeButton;
    ButtonVM _customizeButton;
    CheckBoxVM _hideButton;
    ButtonVM _detailsButton;

    LayerInfoDialog _layerInfoDialog;
    LayerCustomizationDialog _layerCustomizationDialog;

    LayerManagerDialog(String id) : super(id, hasCancelButton: false) {

        _layerInfoDialog = new LayerInfoDialog("#layerInfoDialog");
        _layerCustomizationDialog = new LayerCustomizationDialog("#layerCustomizationDialog");

        _addButton = new ButtonVM("#layerManagerDialog_add", (_) => log("add layer"));

        _removeButton = new ButtonVM("#layerManagerDialog_remove", (_) {
            _hub.commands.removeLayer(_listbox.value);
            _listbox.remove(_listbox.value);
        });

        _customizeButton =
                new ButtonVM("#layerManagerDialog_customize", (_) {
            _layerCustomizationDialog.target = _listbox.value;
            _layerCustomizationDialog.show();
        });

        _detailsButton = new ButtonVM("#layerManagerDialog_details", (_) {
            _layerInfoDialog.target = _listbox.value;
            _layerInfoDialog.show();
        });

        _hideButton = new CheckBoxVM("#layerManagerDialog_hide", true);
        _hideButton.setClickHandler((_) {
            Layer layer = _listbox.value;
            if (layer is VisibilityControl) {
                (layer as VisibilityControl).visible = _hideButton.value;
            }
        });

        _listbox = new BetterListBoxVM("#layerList", _updateButtons);

        _updateButtons();
    }

    @override
    void _show() {
        _listbox.clear();

        for (var layer in _hub.layerManager.layers) {
            _listbox.add(layer);
        }

        _updateButtons();
        _listbox.value = null;
    }

    @override
    void _hide() {}

    void _updateButtons([_ = null]) {
        final disabled = (_listbox.value == null);

        _removeButton.disabled = disabled;
        _customizeButton.disabled = disabled;
        _detailsButton.disabled = disabled;

        if (disabled) {
            _hideButton.disabled = true;
        } else {
            _hideButton.disabled = (_listbox.value is! VisibilityControl);
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

    BetterListBoxVM(String id, Function this._onSelection)
            : super(id) {
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
