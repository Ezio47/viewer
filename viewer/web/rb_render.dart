library rb_render;

import 'package:polymer/polymer.dart';
import 'dart:core';
import 'hub.dart';


@CustomTag('rb-render')
class RbRender extends PolymerElement
{
  RbRender.created() : super.created();

  @override
  void attached() {
    super.attached();

    var canvas =  this.shadowRoot.querySelector("#container");
    assert(canvas != null);

    hub.renderUI = this;
    hub.canvas = canvas;

    canvas.onMouseMove.listen(onMyMouseMove);
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

