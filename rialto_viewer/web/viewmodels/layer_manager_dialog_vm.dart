// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class LayerManagerDialogVM extends DialogVM {
    ListBoxVM<_LayerItem> _listbox;
    bool hasData;
    var selection;
    //bool selectionEnabled = true;
    Hub _hub;
    ColorizerDialogVM _colorizer;
    InfoVM _info;
    Map<String, Layer> _layers = new Map<String, Layer>();
    CheckBoxVM _layerVisible;

    LayerManagerDialogVM(String id) : super(id) {
        _hub = Hub.root;

        _listbox = new ListBoxVM<_LayerItem>("layerManagerDialog_layers");
        _listbox.setSelectHandler(_selectHandler);

        _colorizer = new ColorizerDialogVM("colorizerDialog");
        _info = new InfoVM("infoDialog", this);

        _layerVisible = new CheckBoxVM("infoDialog_layerVisible", false);
        _layerVisible.setClickHandler(_layerVisibleHandler);

        _hub.events.AddLayerCompleted.subscribe(_handleAddLayerCompleted);
        _hub.events.RemoveLayerCompleted.subscribe(_handleRemoveLayerCompleted);
    }

    @override
    void _open() {
        _listbox.clear();

        var names = _layers.keys.toList();
        names.sort();

        for (var name in names) {
            var item = new _LayerItem(_layers[name]);
            _listbox.add(item);
        }

        _layerVisible.clearState();
    }

    @override
    void _close(bool okay) {}

    void _handleAddLayerCompleted(Layer layer) {
        _layers[layer.name] = layer;
    }

    void _handleRemoveLayerCompleted(String name) {
        _layers.remove(name);
    }

    void _layerVisibleHandler(var e) {
        List<_LayerItem> items = _listbox.getCurrentSelection();
        if (items == null) return;
        if (items[0] == null) return;
        Layer layer = items[0].layer;

        layer.visible = _layerVisible.value;
        log("Visibility of ${layer.name} changed to ${layer.visible}");
    }

    void _selectHandler(var e) {
        List<_LayerItem> items = _listbox.getCurrentSelection();
        if (items == null) return;
        if (items[0] == null) return;
        Layer layer = items[0].layer;

        log("${layer.name} selected");

        _layerVisible.value = layer.visible;
    }

    Layer get currentSelection {
        var list = _listbox.getCurrentSelection();
        if (list == null || list.isEmpty || list[0] == null) return null;
        return list[0].layer;
    }

    /*
    void toggleLayer(Event e, var detail, Node target) {
        var checkbox = target as InputElement;
        var item = _listbox.list[int.parse(checkbox.id)].data;
        _hub.eventRegistry.DisplayLayer.fire(new DisplayLayerData(item.layer.name, checkbox.checked));
    }
    */
}



class _LayerItem {
    Layer layer;

    _LayerItem(Layer this.layer);

    String toString() => "${layer.name}";
}
