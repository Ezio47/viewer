import 'package:polymer/polymer.dart';
import 'dart:core';
import 'dart:html';


@CustomTag('rb-viewer')
class RbViewer extends PolymerElement {
  @observable String xyz="......";
  
  RbViewer.created() : super.created();
    
  @override
  void attached() {
    super.attached();
  }
  
  @override
  void detached() {
    super.detached();
  }
  
}
