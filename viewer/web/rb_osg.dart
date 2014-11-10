import 'dart:html';
import 'package:polymer/polymer.dart';
import 'dart:core';
import "graph.dart";
import 'display.dart';


@CustomTag('rb-osg')
class RbOsg extends PolymerElement {
  @published double mousePositionX;
  @published double mousePositionY;
  @published bool showAxes;
  
  Map<String, Graph> _graphs = new Map();
  Element _canvas;
  Display _webgl;
  
  RbOsg.created() : super.created();
  
   
  @override
  void attached() {
    super.attached();
    
    _canvas =  this.shadowRoot.querySelector("#View");
    _canvas =  this.shadowRoot.querySelector("#container");
    assert(_canvas != null);

    mousePositionX = 0.0;
    mousePositionY = 0.0;

    _canvas.onMouseMove.listen(onDocumentMouseMove);
    
   
  }
  
  @override
  void detached() {
    super.detached();
  }
  
  showAxesChanged(var o, var n)
  {
    if (_webgl != null)
    {
      if (n)
      {
        _webgl.addAxes();
      }
      else
      {
        _webgl.removeAxes();
      }
    }
  }
  
  
  onDocumentMouseMove( event )
  {
    mousePositionX = _webgl.mouseX;
    mousePositionY = _webgl.mouseY;
  }

  
  void addGraph(String s)
  {
    Graph g = new Graph(s);
    _graphs[s] = g;
    
    //_osgBridge.doOSG(_canvas, g);
    _webgl = new Display();
    _webgl.init(_canvas);
    _webgl.animate(0);
    
  }

  void removeGraph(String s)
  {
    _graphs.remove(s);
  }
}

