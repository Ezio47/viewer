import 'dart:html';
import 'package:polymer/polymer.dart';
import 'dart:js';
import 'dart:core';
import "graph.dart";
import 'osg_bridge.dart';


@CustomTag('rb-osg')
class RbOsg extends PolymerElement {
  @published String mousePosition;
  Map<String, Graph> _graphs = new Map();
  CanvasElement _canvas;
  OSGBridge _osgBridge;
  
  
  RbOsg.created() : super.created();
  
   
  @override
  void attached() {
    super.attached();
    
    _canvas =  this.shadowRoot.querySelector("#View");
    assert(_canvas != null);
    
    _osgBridge = new OSGBridge();
    
    mousePosition = "(12.345, 67.890)";
  }
  
  @override
  void detached() {
    super.detached();
  }
  

  void addGraph(String s)
  {
    Graph g = new Graph(s);
    _graphs[s] = g;
    
    _osgBridge.doOSG(_canvas, g);
  }

  void removeGraph(String s)
  {
    _graphs.remove(s);
  }
}

