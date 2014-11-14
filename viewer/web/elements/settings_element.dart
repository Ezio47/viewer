library settings_element;


import 'dart:core';
import 'dart:html';
import 'package:polymer/polymer.dart';
import '../hub.dart';


@CustomTag('settings-element')
class SettingsElement extends PolymerElement
{
  @published ObservableList<CloudFile> files = new ObservableList();
  @published bool showAxes = false;
  @published bool showBbox = false;

  SettingsElement.created() : super.created();

  @override
  void attached() {
    super.attached();

    hub.settingsUI = this;
    initSettings();
  }

  @override
  void detached() {
    super.detached();
  }

  void initSettings()
  {
  }

  void doAddFile(String s)
  {
    files.add(new CloudFile(s));
  }

  void doRemoveFile(String s)
  {
      files.removeWhere((f) => f.name==s);
  }

  void toggleAxes(Event e, var detail, Node target) {
    var button = target as InputElement;
    hub.doToggleAxes(button.checked);
  }

  void toggleBbox(Event e, var detail, Node target) {
    var button = target as InputElement;
    hub.doToggleBbox(button.checked);
  }

  void goHome(Event e, var detail, Node target) {
    hub.goHome();
  }

  void openFile(Event e, var detail, Node target) {
    var dlg = this.shadowRoot.querySelector("#openDialog");
    dlg.showModal();
  }

  void openFileCancel(Event e, var detail, Node target) {
    DialogElement dlg = this.shadowRoot.querySelector("#openDialog");
    dlg.close("");
    return;
  }

  void openFileOkay(Event e, var detail, Node target) {
    DialogElement dlg = this.shadowRoot.querySelector("#openDialog");
    dlg.close("");
    var txt = this.shadowRoot.querySelector("#filenamearea");
    hub.doAddFile(txt.value);
    txt.value = "";
  }

  void toggleFile(Event e, var detail, Node target) {
    var button = target as ButtonElement;
    window.alert("toggle for ${button.id.toString()}");
  }

  void infoFile(Event e, var detail, Node target) {
    var button = target as ButtonElement;
    window.alert("info for ${button.id.toString()}");
  }

  void colorizeFile(Event e, var detail, Node target) {
    var button = target as ButtonElement;
    hub.doColorizeFile(button.id.toString());
  }

  void deleteFile(Event e, var detail, Node target)
  {
    int id = int.parse(target.parent.id);
  //  var button = target as ButtonElement;
  //  hub.doRemoveFile(button.id.toString());
    return;
  }



  @observable bool selectionEnabled = true;

  void selectionMade( e )
  {
      window.alert("selection made ${e.detail.data.toString()}");
      if (e.detail.data.checked)
      {
       // files.remove(e.detail.data);
      }
  }

  @override
  void ready()
  {
      $[ 'kore-list' ].on ['core-activate'].listen( handleListChange );
  }

  void handleListChange(e)
  {
    window.alert("list change ${e.detail.data.toString()}");
  }

  @observable var selection;
}


class CloudFile extends Observable{
  @observable String name;
  @observable bool checked;
  CloudFile(this.name) { checked=false; }
  String toString() => "<$name $checked>";
}
