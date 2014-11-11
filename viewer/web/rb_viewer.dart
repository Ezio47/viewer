library rb_viewer;

import 'package:polymer/polymer.dart';
import 'dart:core';
import 'hub.dart';

@CustomTag('rb-viewer')
class RbViewer extends PolymerElement
{
  RbViewer.created() : super.created();


  @override
  void attached() {
    super.attached();

    hub.doAddFile("1");
    hub.doToggleAxes(true);
  }


  @override
  void detached() {
    super.detached();
  }
}
