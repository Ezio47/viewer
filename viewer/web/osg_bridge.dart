import 'dart:html';
import 'dart:js';
import 'dart:core';
import 'graph.dart';


class OSGBridge
{
  var _ns_osg;
  var _ns_osgViewer;
  var _ns_osgDB;
  
  
  OSGBridge()
  {
    _ns_osg = context['OSG'];
    assert(_ns_osg != null);
    
    _ns_osgViewer = _ns_osg['osgViewer'];
    assert(_ns_osgViewer != null);  
    
    _ns_osgDB = _ns_osg['osgDB'];
    assert(_ns_osgDB != null);
  }
  
  
  void doOSG(Element canvas, Graph g)
  {      
    /*
     //var myModel = Graph.getCubeModel();
     var myModel = g;
     
     //var osg = window.OSG.osg;
     var osg = _ns_osg['osg'];
           
     //viewer = new osgViewer.Viewer( canvas );
     var viewer = new JsObject(_ns_osgViewer['Viewer'], [canvas]);
      
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
     var tempData = _ns_osgDB.callMethod("parseSceneGraph", [tempModelJson]);
     
     rotate.callMethod("addChild", [tempData]);
     
     //viewer.setSceneData( rotate );
     viewer.callMethod("setSceneData", [rotate]);
     
     //viewer.run();
     viewer.callMethod("run", []);
     */
    
     var xxx = context['xxx'];
     assert(xxx == 5);

     var yyy = context['yyy'];
     assert(yyy != null);
     
     var json = new JsObject.jsify(g.points);
     yyy.callMethod('Go', [canvas, json]);
     
     return;
  }
  
}

