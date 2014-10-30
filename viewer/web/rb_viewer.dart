import 'package:polymer/polymer.dart';
import 'dart:core';


@CustomTag('rb-viewer')
class RbViewer extends PolymerElement {
  @published String g_mousePosition;
  @published String g_filename;
  
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
