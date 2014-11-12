library viewer_element;


import 'dart:core';
import 'package:polymer/polymer.dart';
import '../hub.dart';


@CustomTag('viewer-element')
class ViewerElement extends PolymerElement
{
  ViewerElement.created() : super.created();


  @override
  void attached() {
    super.attached();

    hub.doAddFile("5");
  }


  @override
  void detached() {
    super.detached();
  }
}
