library settings_element;


import 'dart:core';
import 'dart:html';
import 'package:polymer/polymer.dart';
import '../hub.dart';
import 'package:paper_elements/paper_icon_button.dart';


@CustomTag('settings-element')
class SettingsElement extends PolymerElement {
    @published ObservableList<CloudFile> files = new ObservableList();
    @published bool hasData;

    Hub _hub = Hub.root;

    SettingsElement.created() : super.created();

    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
        $["file-list"].on['core-activate'].listen(handleListChange);

        _hub.settingsUI = this;
    }

    @override
    void detached() {
        super.detached();
    }

    void toggleCollapse2(Event e, var detail, Node target) {
        var e = $["collapse2"];
        var button = target as PaperIconButton;
        button.icon = e.opened ? "rialto-icons-small:chevdown" : "rialto-icons-small:chevup";
        e.toggle();
    }
    void toggleCollapse3(Event e, var detail, Node target) {
        var e = $["collapse3"];
        var button = target as PaperIconButton;
        button.icon = e.opened ? "rialto-icons-small:chevdown" : "rialto-icons-small:chevup";
        e.toggle();
    }
    void toggleCollapse4(Event e, var detail, Node target) {
        var e = $["collapse4"];
        var button = target as PaperIconButton;
        button.icon = e.opened ? "rialto-icons-small:chevdown" : "rialto-icons-small:chevup";
        e.toggle();
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
