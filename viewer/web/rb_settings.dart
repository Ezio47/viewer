import 'dart:html';
import 'package:polymer/polymer.dart';
import 'dart:core';

@CustomTag('rb-settings')
class RbSettings extends PolymerElement {
  @published String filename;
  int _counter;
  
  RbSettings.created() : super.created();
   
  @override
  void attached() {
    super.attached();
    
    initSettings();
  }
  
  @override
  void detached() {
    super.detached();
  }
  
  void initSettings()
  {
    filename = " ";
    _counter = 0;
  }
  
  void toggleFileDialog(Event e, var detail, Node target) {
    var fileDialog = $['filedialog'];
    fileDialog.toggle();
  }


  void toggleColorsDialog(Event e, var detail, Node target) {
    var dlg = $['colorsdialog'];
    dlg.toggle();
  }

  void openFile(Event e, var detail, Node target) {
    filename = "file_" + _counter.toString() + ".las";
    ++_counter;
  }
}
