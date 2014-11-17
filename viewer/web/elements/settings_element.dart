library settings_element;


import 'dart:core';
import 'dart:html';
import 'package:polymer/polymer.dart';
import '../hub.dart';
import 'package:paper_elements/paper_dialog.dart';


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
        dlg.toggle();
    }

    void openFileCancel(Event e, var detail, Node target) {
        var dlg = this.shadowRoot.querySelector("#openDialog") as PaperDialog;
        dlg.toggle();
    }

    void openFileOkay(Event e, var detail, Node target) {
        var dlg = this.shadowRoot.querySelector("#openDialog") as PaperDialog;
        dlg.toggle();
        InputElement elem = this.shadowRoot.querySelector("#filenamearea") as InputElement;
        var txt = elem.value;
        if (txt.trim().isEmpty == false) {
            hub.doAddFile(txt);
        }
        elem.value = "";
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

    void selectionMade(e) {
    }

    void handleListChange(e) {
        //window.alert("list change ${e.detail.data.toString()}");
    }

    @observable var selection;
    @observable bool selectionEnabled = true;
}


class CloudFile extends Observable {
    @observable String name;
    @observable bool checked;
    CloudFile(this.name) {
        checked = true;
    }
    String toString() => "<$name $checked>";
}
