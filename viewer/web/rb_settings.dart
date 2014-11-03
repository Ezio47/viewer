import 'dart:html';
import 'package:polymer/polymer.dart';
import 'dart:core';

@CustomTag('rb-settings')
class RbSettings extends PolymerElement {
  @published String filename;
  @published String servername;
  @published List<String>files = toObservable([]);
  
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
    filename = "xxx";
    servername = "localhost:8080";
    files.addAll(["foo.las", "bar.las", "baz.las"]);
  }

  void openFile(Event e, var detail, Node target) {
    window.alert(filename);
  }
}
