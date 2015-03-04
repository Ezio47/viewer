// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class LayerManagerDialogVM extends DialogVM {
    ListBoxVM _listbox;
    CheckBoxVM _layerVisible;

    InfoVM _info;

    LayerManagerDialogVM(String id) : super(id) {

        _info = new InfoVM("#infoDialog", this);

        _listbox = new ListBoxVM("#layerManagerDialog_layers", onSelect: _selectHandler);

        _layerVisible = new CheckBoxVM("#layerManager_layerVisible", false);

        _register(_listbox);
        _register(_layerVisible);
    }

    @override
    void _show() {
        _listbox.clear();

        Map layers = _hub.layerManager.layers;
        var names = layers.keys.toList();
        names.sort();

        for (var name in names) {
            _listbox.add(name);
        }

        _listbox.value = names.length == 0 ? "" : names[0]; // TODO: handle no layers yet loaded
        _selectHandler(null);
    }

    @override
    void _hide() {

        var item = _listbox.value;
        if (item == null) return;

        Layer layer = _hub.layerManager.layers[item];

        if (layer is VisibilityControl) {
            VisibilityControl vc = layer as VisibilityControl;
            vc.visible = _layerVisible.value;
            log("Visibility of ${layer.name} changed to ${vc.visible}");
        }
    }

    // used by the child Info dialog
    String get currentSelection => _listbox.value;

    void _selectHandler(_) {
        var item = _listbox.value;
        if (item == null) return;

        Layer layer = _hub.layerManager.layers[item];

        log("${layer.name} selected");

        if (layer is VisibilityControl) {
            _layerVisible.disabled = false;
            _layerVisible.value = (layer as VisibilityControl).visible;
        } else {
            _layerVisible.disabled = true;
        }
    }
}
