import 'dart:html';
import 'package:polymer/polymer.dart';
import 'dart:js';
import 'dart:core';
import "graph.dart";
import 'osg_bridge.dart';
import 'webgl.dart';


@CustomTag('rb-osg')
class RbOsg extends PolymerElement {
  @published String mousePosition;
  Map<String, Graph> _graphs = new Map();
  /*Canvas*/Element _canvas;
  OSGBridge _osgBridge;
  webgl _webgl;
  
  RbOsg.created() : super.created();
  
   
  @override
  void attached() {
    super.attached();
    
    _canvas =  this.shadowRoot.querySelector("#View");
    _canvas =  this.shadowRoot.querySelector("#container");
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
    
    //_osgBridge.doOSG(_canvas, g);
    _webgl = new webgl();
    _webgl.init(_canvas);
    _webgl.animate(0);
    
  }

  void removeGraph(String s)
  {
    _graphs.remove(s);
  }
}

