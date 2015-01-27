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
    }

    @override
    void _open() {}

    @override
    void _close(bool okay) {}

    PointCloud get currentSelection {
        var list = _listbox.getCurrentSelection();
        if (list==null) return null;
        String webpath = list[0].webpath;
        var rpc = _hub.renderablePointCloudSet.getCloud(webpath);
        return rpc;
    }

    void toggleLayer(Event e, var detail, Node target) {
        var checkbox = target as InputElement;
        var item = _listbox.list[int.parse(checkbox.id)].data;
        _hub.eventRegistry.DisplayLayer.fire(new DisplayLayerData(item.webpath, checkbox.checked));
    }


    void deleteFile(Event e, var detail, Node target) {
        if (selection != null) {
            assert(selection is _LayerItem);
            _hub.eventRegistry.CloseFile.fire(selection.webpath);
        }
        return;
    }
}



class _LayerItem {
    String webpath;
    String displayName;
    bool checked;
    _LayerItem(this.webpath, this.displayName) {
        checked = true;
    }
    String toString() => "<$displayName $checked>";
}
