library layer_panel;


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


    void doAddFile(String name, String fullpath) {
        files.add(new _LayerItem(name, fullpath));
        hasData = files.length > 0;
    }

    void doRemoveFile(String fullpath) {
        files.removeWhere((f) => f.fullpath == fullpath);
        hasData = files.length > 0;
    }

    void openFile(Event e, var detail, Node target) {
        // kludge so we can set isServerOpen correctly when using a bootscript
        _hub.serverBrowserElement.openPanel();
    }

    void toggleFile(Event e, var detail, Node target) {
        var button = target as ButtonElement;
        window.alert("toggle for ${button.id.toString()}");
    }


    void deleteFile(Event e, var detail, Node target) {
        if (selection != null) {
            assert(selection is _LayerItem);
            _hub.commandRegistry.doRemoveFile(selection.fullpath);
        }
        return;
    }

    void selectionMade(CustomEvent e) { }
}


class _LayerItem extends Observable {
    @observable String name;
    @observable String fullpath;
    @observable bool checked;
    _LayerItem(this.name, this.fullpath) {
        checked = true;
    }
    String toString() => "<$name $checked>";
}
