import 'package:polymer/polymer.dart';
import 'dart:core';
import 'dart:html';


@CustomTag('rb-status-view')
class RbStatusView extends PolymerElement {
  @observable String data="-data-";
  
  RbStatusView.created() : super.created();
    
  @override
  void attached() {
    super.attached();
    
    
  }
  
  @override
  void detached() {
    super.detached();
  }
  
}
