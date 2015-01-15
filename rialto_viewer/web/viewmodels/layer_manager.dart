// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class LayerManagerVM extends DialogVM {
    SelectElement _select;
    ListBoxVM<_LayerItem> items;
    bool hasData;
    var selection;
    //bool selectionEnabled = true;
    Hub _hub;

    LayerManagerVM(DialogElement dialogElement, var dollar) : super(dialogElement, dollar) {
        _select = $["layerManagerDialog_layers"];
        assert(_select != null);

        items = new ListBoxVM<_LayerItem>(_select);

        ["a", "b", "c"].forEach((f) {
            var opt = new OptionElement(value: f);
            opt.text = "sss";
            _select.children.add(opt);
        });

//        ButtonElement openServer = $["serverManagerDialog_openServer"];
  //      openServer.onClick.listen((ev) => _serverManager.open());

        _hub = Hub.root;

        _hub.eventRegistry.OpenFileCompleted.subscribe((webpath) {
            final String displayName = _hub.proxy.getFileProxy(webpath).displayName;
            var p = new _LayerItem(webpath, displayName);
            items.add(p, p.displayName);
            hasData = items.length > 0;
        });

        _hub.eventRegistry.CloseFileCompleted.subscribe((webpath) {
            items.removeWhere((f) => f.webpath == webpath);
            hasData = items.length > 0;
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
