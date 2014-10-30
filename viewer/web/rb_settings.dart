import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';
import 'dart:core';

@CustomTag('rb-settings')
class RbSettings extends PolymerElement {
  @published String counter='00:00';
  
  RbSettings.created() : super.created();
  
  Stopwatch mywatch = new Stopwatch();
  Timer mytimer;
  
//  ButtonElement stopButton;
  
  @override
  void attached() {
    super.attached();

    //startButton = $['startButton'];
    //stopButton.disabled = true;
  }
  
  @override
  void detached() {
    super.detached();
    mytimer.cancel();
  }
  
  void doFileDialog(Event e, var detail, Node target) {}
  
  void doDisplayDialog(Event e, var detail, Node target) {}
  
  void doActionDialog(Event e, var detail, Node target) {}
}
