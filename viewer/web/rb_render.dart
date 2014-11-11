library rb_render;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'dart:core';
import "point_cloud.dart";
import 'display.dart';
import 'hub.dart';
import 'cloud_generator.dart';


@CustomTag('rb-render')
class RbRender extends PolymerElement {
  @published double mousePositionX;
  @published double mousePositionY;
  
  Map<String, PointCloud> _pointclouds = new Map();
  Element _canvas;
  Display _webgl;
  
  RbRender.created() : super.created();
  
   
  @override
  void attached() {
    super.attached();
    
    _canvas =  this.shadowRoot.querySelector("#View");
    _canvas =  this.shadowRoot.querySelector("#container");
    assert(_canvas != null);

    mousePositionX = 0.0;
    mousePositionY = 0.0;

    _canvas.onMouseMove.listen(onDocumentMouseMove);
    
    hub.renderUI = this;
  }
  
  @override
  void detached() {
    super.detached();
  }
  
  void showAxes(bool on)
  {
    if (on)
    {
      _webgl.addAxes(); 
    }
    else
    {
      _webgl.removeAxes();
    }
  }
  
  onDocumentMouseMove( event )
  {
    mousePositionX = _webgl.mouseX;
    mousePositionY = _webgl.mouseY;
    hub.mouseMoved(mousePositionX,  mousePositionY);
  }

  
  void addGraph(String s)
  {
    var map = CloudGenerator.generate(s);
    _pointclouds[s] = new PointCloud(map);
    
    _webgl = new Display();
    _webgl.init(_canvas);
    _webgl.animate(0);
  }

  void removeGraph(String s)
  {
    _pointclouds.remove(s);
  }
}

