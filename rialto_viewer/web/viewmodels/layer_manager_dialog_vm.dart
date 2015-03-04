// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class LayerManagerDialogVM extends DialogVM {
    ListBoxVM<_LayerItem> _listbox;
    CheckBoxVM _layerVisible;

    ColorizerDialogVM _colorizer;
    InfoVM _info;

    Map<String, Layer> _layers = new Map<String, Layer>();

    LayerManagerDialogVM(String id) : super(id) {

        _colorizer = new ColorizerDialogVM("#colorizerDialog");

        _info = new InfoVM("#infoDialog", this);

        _listbox = new ListBoxVM<_LayerItem>("#layerManagerDialog_layers");
        _listbox.setSelectHandler(_selectHandler);

        _layerVisible = new CheckBoxVM("#infoDialog_layerVisible", false);

        register(_listbox);
        register(_layerVisible);

        _hub.events.AddLayerCompleted.subscribe(_handleAddLayerCompleted);
        _hub.events.RemoveLayerCompleted.subscribe(_handleRemoveLayerCompleted);
    }

    @override
    void _show() {
        _listbox.clear();

        var names = _layers.keys.toList();
        names.sort();

        for (var name in names) {
            var item = new _LayerItem(_layers[name]);
            _listbox.add(item);
        }

        _listbox.value = null;
    }

    @override
    void _hide() {
        _effectLayerVisibility();
    }

    void _handleAddLayerCompleted(Layer layer) {
        _layers[layer.name] = layer;
    }

    void _handleRemoveLayerCompleted(String name) {
        _layers.remove(name);
    }

    void _effectLayerVisibility() {
        var item = _listbox.value;
        if (item == null) return;
        Layer layer = item.layer;

        if (layer is VisibilityControl) {
            VisibilityControl vc = layer as VisibilityControl;
            vc.visible = _layerVisible.value;
            log("Visibility of ${layer.name} changed to ${vc.visible}");
        }
    }

    Layer get currentSelection => _listbox.value.layer;

    void _selectHandler(_) {
        var item = _listbox.value;
        if (item == null) return;

        Layer layer = item.layer;

        log("${layer.name} selected");

        if (layer is VisibilityControl) {
            _layerVisible.disabled = false;
            _layerVisible.value = (layer as VisibilityControl).visible;
        } else {
            _layerVisible.disabled = true;
        }
    }
}



class _LayerItem {
    Layer layer;

    _LayerItem(Layer this.layer);

    String toString() => "${layer.name}";
}
