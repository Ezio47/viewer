library rb_settings;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'dart:core';
import 'hub.dart';

@CustomTag('rb-settings')
class RbSettings extends PolymerElement {
  @published List<String> files = new List();
  @published bool showAxes = false;
  
  RbSettings.created() : super.created();
   
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
    files.add(s);
  }
  
  void doRemoveFile(String s)
  {
    files.remove(s);
  }
  
  void toggleAxes(Event e, var detail, Node target) {
    var button = target as InputElement;
    hub.showAxes(button.checked);
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
    var txt = this.shadowRoot.querySelector("#filenamearea");
    hub.addFile(txt.value);
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
    window.alert("colorize for ${button.id.toString()}");
  }
  
  void deleteFile(Event e, var detail, Node target)
  {
    var button = target as ButtonElement;
    hub.removeFile(button.id.toString());
    return;
  }
}
