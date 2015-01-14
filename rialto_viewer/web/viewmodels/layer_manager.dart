// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;




class LayerManagerVM extends ViewModel {
    SelectElement _select;
    ServerManagerVM _serverManager;
    ControlledList<_LayerItem> items;
    bool hasData;
    var selection;
    //bool selectionEnabled = true;
    Hub _hub;

    LayerManagerVM(DialogElement dialogElement, var dollar) : super(dialogElement, dollar) {
        _select = $["layerManagerDialog_files"];
        assert(_select != null);

        items = new ControlledList<_LayerItem>(_select);

        ["a", "b", "c"].forEach((f) {
            var opt = new OptionElement(value: f);
            opt.text = "sss";
            _select.children.add(opt);
        });

        var serverManagerDialog = $["serverManagerDialog"];
        _serverManager = new ServerManagerVM(serverManagerDialog, $);

        ButtonElement add = $["layerManagerDialog_add"];
        add.onClick.listen((ev) => _serverManager.open());

        _hub = Hub.root;

        _hub.eventRegistry.OpenFileCompleted.subscribe((webpath) {
            final String displayName = _hub.proxy.getFileProxy(webpath).displayName;
            items.add(new _LayerItem(webpath, displayName));
            hasData = items.length > 0;
        });

        _hub.eventRegistry.CloseFileCompleted.subscribe((webpath) {
            items.removeWhere((f) => f.webpath == webpath);
            hasData = items.length > 0;
        });
    }

    void openFile(Event e, var detail, Node target) {
        _serverManager.open();
    }

    void toggleLayer(Event e, var detail, Node target) {
        var checkbox = target as InputElement;
        var item = items.list[int.parse(checkbox.id)].data;
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
