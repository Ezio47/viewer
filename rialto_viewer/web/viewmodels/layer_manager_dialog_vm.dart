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
        _info = new InfoVM("infoDialog");

        _hub = Hub.root;

        _hub.eventRegistry.OpenFileCompleted.subscribe((webpath) {
            final String displayName = _hub.proxy.getFileProxy(webpath).displayName;
            var p = new _LayerItem(webpath, displayName);
            _listbox.add(p, p.displayName);
            hasData = _listbox.length > 0;
        });

        _hub.eventRegistry.CloseFileCompleted.subscribe((webpath) {
            _listbox.removeWhere((f) => f.webpath == webpath);
            hasData = _listbox.length > 0;
        });

    }

    @override
    void _open() {}

    @override
    void _close(bool okay) {}
    void openFile(Event e, var detail, Node target) {

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
