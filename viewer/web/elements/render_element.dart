library render_element;


import 'dart:core';
import 'package:polymer/polymer.dart';
import '../hub.dart';


@CustomTag('render-element')
class RenderElement extends PolymerElement
{
  RenderElement.created() : super.created();

  @override
  void attached() {
    super.attached();

    var canvas =  this.shadowRoot.querySelector("#container");
    assert(canvas != null);

    hub.renderUI = this;
    hub.canvas = canvas;

    canvas.onMouseMove.listen(onMyMouseMove);

    hub.makeRenderer();
  }

  @override
  void detached() {
    super.detached();
  }


  void onMyMouseMove(event)
  {
    hub.doMouseMoved();
  }
}

