library layer_panel;


import 'dart:core';
import 'dart:html';
import 'package:polymer/polymer.dart';
import '../hub.dart';


@CustomTag('layer-panel')
class LayerPanel extends PolymerElement {
    @published ObservableList<CloudFile> files = new ObservableList();
    @published bool hasData;

    Hub _hub = Hub.root;

    LayerPanel.created() : super.created();

    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
        $["file-list"].on['core-activate'].listen(handleListChange);

        _hub.layerPanel = this;
    }

    @override
    void detached() {
        super.detached();
    }



    void doAddFile(String name, String fullpath) {
        files.add(new CloudFile(name, fullpath));
        hasData = files.length > 0;
    }

    void doRemoveFile(String fullpath) {
        files.removeWhere((f) => f.fullpath == fullpath);
        hasData = files.length > 0;
    }

    void openFile(Event e, var detail, Node target) {
        var e = $["collapse6"];
        e.toggle();
    }

    void toggleFile(Event e, var detail, Node target) {
        var button = target as ButtonElement;
        window.alert("toggle for ${button.id.toString()}");
    }


    void deleteFile(Event e, var detail, Node target) {
        if (selection != null) {
            assert(selection is CloudFile);
            _hub.doRemoveFile(selection.fullpath);
        }
        return;
    }

    void selectionMade(CustomEvent e) {
    }

    void handleListChange(e) {
        //window.alert("list change ${e.detail.data.toString()}");
    }

    @observable var selection;
    @observable bool selectionEnabled = true;

}


class CloudFile extends Observable {
    @observable String name;
    @observable String fullpath;
    @observable bool checked;
    CloudFile(this.name, this.fullpath) {
        checked = true;
    }
    String toString() => "<$name $checked>";
}
