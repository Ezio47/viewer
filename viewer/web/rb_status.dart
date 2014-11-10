import 'package:polymer/polymer.dart';
import 'dart:core';


@CustomTag('rb-status')
class RbStatus extends PolymerElement {
  @published double mousePositionX;
  @published double mousePositionY;
  
  RbStatus.created() : super.created();
    
  @override
  void attached() {
    super.attached();
    
    
  }
  
  @override
  void detached() {
    super.detached();
  }
  
}
