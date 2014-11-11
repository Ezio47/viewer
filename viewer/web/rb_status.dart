library rb_status;

import 'package:polymer/polymer.dart';
import 'dart:core';
import 'hub.dart';


@CustomTag('rb-status')
class RbStatus extends PolymerElement {
  @published double mousePositionX;
  @published double mousePositionY;
  
  RbStatus.created() : super.created();
    
  @override
  void attached() {
    super.attached();
    
    hub.statusUI = this;    
  }
  
  @override
  void detached() {
    super.detached();
  }
  
  void doMousePosition(double x, double y)
  {
    mousePositionX = x;
    mousePositionY = y;
  }
}
