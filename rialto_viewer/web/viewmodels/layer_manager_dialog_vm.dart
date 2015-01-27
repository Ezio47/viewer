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

    LayerManagerDialogVM(String id) : super(id) {
        _listbox = new ListBoxVM<_LayerItem>("layerManagerDialog_layers");

        _colorizer = new ColorizerDialogVM("colorizerDialog");
        _info = new InfoVM("infoDialog", this);

        _hub = Hub.root;

        _listbox.setSelectHandler(_selectHandler);
    }

    @override
    void _open() {
        _listbox.clear();

        Map layers = _hub.layerManager.layers;
        for (var layer in layers.keys) {
            var item = new _LayerItem(layers[layer]);
            _listbox.add(item);
        }
    }

    @override
    void _close(bool okay) {}

    void _selectHandler(var e) {
        List<_LayerItem> items = _listbox.getCurrentSelection();
        if (items==null) return;
        if (items[0] == null) return;
    }

    Layer get currentSelection {
        var list = _listbox.getCurrentSelection();
        if (list==null || list[0] == null) return null;
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
