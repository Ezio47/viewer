import 'dart:html';
import 'package:polymer/polymer.dart';
import 'dart:js';
import 'dart:core';
import "graph.dart";


@CustomTag('rb-osg')
class RbOsg extends PolymerElement {
  @published String mousePosition;
  Map<String, Graph> _graphs = new Map();
  CanvasElement _canvas;
  
  RbOsg.created() : super.created();
  
   
  @override
  void attached() {
    super.attached();
    
    _canvas =  this.shadowRoot.querySelector("#View");
    assert(_canvas != null);
    
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
    
    doOSG(_canvas, g);
  }

  void removeGraph(String s)
  {
    _graphs.remove(s);
  }
}


void doOSG(Element canvas, Graph g)
{      
     //var myModel = Graph.getCubeModel();
     var myModel = g;
     
     //var osg = window.OSG.osg;
     var OSG = context['OSG'];
     var osg = OSG['osg'];
     
     //var osgViewer = window.OSG.osgViewer;
     var osgViewer = OSG['osgViewer'];
     
     //var osgDB = window.OSG.osgDB;
     var osgDB = OSG['osgDB'];
     
     //viewer = new osgViewer.Viewer( canvas );
     var viewer = new JsObject(osgViewer['Viewer'], [canvas]);
      
     //viewer.init();
     viewer.callMethod('init', []);
    
     //viewer.setupManipulator();
     viewer.callMethod("setupManipulator", []);
     
     //var rotate = new osg.MatrixTransform();
     var rotate = new JsObject(osg['MatrixTransform'], []);
     
     // osg.Matrix.makeRotate( -Math.PI * 0.5, 1, 0, 0, rotate.getMatrix() );
     var tmp = rotate.callMethod("getMatrix", []);
     var Math_PI = 3.14159;
     osg["Matrix"].callMethod("makeRotate", [ -Math_PI * 0.5, 1, 0, 0, tmp] );
  
     //Q.when( osgDB.parseSceneGraph( getModel() ) ).then( function ( data ) {
     //    rotate.addChild( data );
     //} );
  
     var tempModelMap = myModel.points;
     var tempModelJson = new JsObject.jsify(tempModelMap);
     var tempData = osgDB.callMethod("parseSceneGraph", [tempModelJson]);
     
     rotate.callMethod("addChild", [tempData]);
     
     //viewer.setSceneData( rotate );
     viewer.callMethod("setSceneData", [rotate]);
     
     //viewer.run();
     viewer.callMethod("run", []);
     
     //reportTimer();
     
     return;
}
