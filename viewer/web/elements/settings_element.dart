library settings_element;


import 'dart:core';
import 'dart:html';
import 'package:polymer/polymer.dart';
import '../hub.dart';
import 'package:paper_elements/paper_dialog.dart';
import '../point_cloud_source.dart';


@CustomTag('settings-element')
class SettingsElement extends PolymerElement {
    @published ObservableList<CloudFile> files = new ObservableList();
    @published bool showAxes = false;
    @published bool showBbox = false;
    @published bool axesbool1 = false;
    @published bool axesbool2 = false;
    @published bool axesbool3 = true;

    SettingsElement.created() : super.created();

    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
        $["file-list"].on['core-activate'].listen(handleListChange);

        hub.settingsUI = this;
    }

    @override
    void detached() {
        super.detached();
    }

    void axesbool1Changed(var oldvalue) {
        hub.doToggleAxes(axesbool1);
        hub.doToggleBbox(axesbool2);
    }

    void axesbool2Changed(var oldvalue) {
        hub.doToggleAxes(axesbool1);
        hub.doToggleBbox(axesbool2);
    }

    void axesbool3Changed(var oldvalue) {
        hub.doToggleAxes(axesbool1);
        hub.doToggleBbox(axesbool2);
    }

    void doAddFile(String s) {
        files.add(new CloudFile(s));
    }

    void doRemoveFile(String s) {
        files.removeWhere((f) => f.name == s);
    }

    void toggleAxes(Event e, var detail, Node target) {
        var button = target as InputElement;
        hub.doToggleAxes(button.checked);
    }

    void toggleBbox(Event e, var detail, Node target) {
        var button = target as InputElement;
        hub.doToggleBbox(button.checked);
    }

    void openFile(Event e, var detail, Node target) {
        var dlg = this.shadowRoot.querySelector("#openDialog") as PaperDialog;

        _pcSource = null;
        _pcSource = new PointCloudServer("http://www.example.com/");
        _pcSource.load();
        loadItems();

        dlg.toggle();
    }

    void openFileCancel(Event e, var detail, Node target) {
        var dlg = this.shadowRoot.querySelector("#openDialog") as PaperDialog;
        dlg.toggle();
    }

    void openFileOkay(Event e, var detail, Node target) {
        /*var dlg = this.shadowRoot.querySelector("#openDialog") as PaperDialog;
        dlg.toggle();
        InputElement elem = this.shadowRoot.querySelector("#filenamearea") as InputElement;
        var txt = elem.value;
        if (txt.trim().isEmpty == false) {
            hub.doAddFile(txt);
        }
        elem.value = "";*/

        assert(_currentItem != null);
        hub.doAddFile(_currentItem.path);
    }

    void toggleFile(Event e, var detail, Node target) {
        var button = target as ButtonElement;
        window.alert("toggle for ${button.id.toString()}");
    }

    void infoFile(Event e, var detail, Node target) {
        if (selection != null) {
            assert(selection is CloudFile);
            window.alert("Info for {$selection.name}");
        }
    }

    void deleteFile(Event e, var detail, Node target) {
        if (selection != null) {
            assert(selection is CloudFile);
            hub.doRemoveFile(selection.name);
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


    @published ObservableList<Item> items = new ObservableList();
    PointCloudSource _pcSource = null;
    PointCloudSource _currentItem = null;

    void loadItems() {
        items.clear();

        if (_pcSource is! PointCloudServer)
            items.add(new Item("..", null));

        for (var s in _pcSource.sources) {
            items.add(new Item(s.path, s));
        }
    }

    void openItem(Event e, var detail, Node target) {

    }

    void itemSelectionMade(CustomEvent e) {
        var item = e.detail.data as Item;
        assert(item != null);
        var source = item.source;
        _currentItem = source;

        if (item.name == "..") {
            _pcSource = _pcSource.parent;
            loadItems();

        } else if (source is PointCloudFile) {
            //window.alert(item.name);

        } else if (source is PointCloudDirectory) {
            _pcSource = source;
            _pcSource.load();
            loadItems();

        } else {
            assert(false);
        }

    }
}


class Item extends Observable {
    Item(this.name, this.source);
    @observable String name;
    PointCloudSource source;
}


class CloudFile extends Observable {
    @observable String name;
    @observable bool checked;
    CloudFile(this.name) {
        checked = true;
    }
    String toString() => "<$name $checked>";
}
