// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

library rialto.viewer.layer_panel;

import 'dart:core';
import 'dart:html';
import 'package:polymer/polymer.dart';
import '../hub.dart';


@CustomTag('layer-panel')
class LayerPanel extends PolymerElement {
    @published ObservableList<_LayerItem> files = new ObservableList();
    @published bool hasData;
    @observable var selection;
    @observable bool selectionEnabled = true;

    Hub _hub = Hub.root;

    LayerPanel.created() : super.created();

    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
        _hub.layerPanel = this;
    }

    @override
    void detached() {
        super.detached();
    }


    void doAddFile(String webpath, String displayName) {
        files.add(new _LayerItem(webpath, displayName));
        hasData = files.length > 0;
    }

    void doRemoveFile(String webpath) {
        files.removeWhere((f) => f.webpath == webpath);
        hasData = files.length > 0;
    }

    void openFile(Event e, var detail, Node target) {
        // kludge so we can set isServerOpen correctly when using a bootscript
        _hub.serverBrowserElement.openDialog();
    }

    void openServer(Event e, var detail, Node target) {
        Hub.root.serverBrowserElement.openDialog();
        return;
    }

    void toggleLayer(Event e, var detail, Node target) {
        var checkbox = target as InputElement;
        var item = files[int.parse(checkbox.id)];
        _hub.eventRegistry.fireDisplayLayer(new DisplayLayerData(item.webpath, checkbox.checked));
    }


    void deleteFile(Event e, var detail, Node target) {
        if (selection != null) {
            assert(selection is _LayerItem);
            _hub.commandRegistry.doRemoveFile(selection.webpath);
        }
        return;
    }

    void selectionMade(CustomEvent e) {
    }
}


class _LayerItem extends Observable {
    @observable String webpath;
    @observable String displayName;
    @observable bool checked;
    _LayerItem(this.webpath, this.displayName) {
        checked = true;
    }
    String toString() => "<$displayName $checked>";
}
