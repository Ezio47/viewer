import 'dart:html';
import 'dart:js';
import 'dart:core';
import 'package:polymer/polymer.dart';
import 'package:core_elements/core_overlay.dart';

Map getModel() {

  var K = 1000;
  var siz = 20 * K;
  
  List colors = [];
  List normals = [];
  List points = [];
  
  for (var i=0; i<siz; i++)
  {
    colors.addAll([1,1,1,1]);
    normals.addAll([1.0, 1.0, 1.0]);
    var pt = (i / siz) * 10.0;
    points.addAll([pt, pt, pt]);
  }
  
  Map m =
  {
  "children": [ {
      "children": [ {
          "attributes": {
            "Color": {
              "elements": colors,
              "itemSize": 4, 
              "type": "ARRAY_BUFFER"
            }, 
            "Normal": {
              "elements": normals,
              "itemSize": 3, 
              "type": "ARRAY_BUFFER"
            }, 
            "Vertex": {
              "elements": points,
              "itemSize": 3, 
              "type": "ARRAY_BUFFER"
            }
          }, 
          "name": "", 
          "primitives": [ {
              "count": siz, 
              "first": 0, 
              "mode": "POINTS"
            }
          ]
        }
      ], 
      "name": "cloud.osg"
    }
  ]
};
  
  return m;
}

int _timer = 0;
void startTimer()
{
  _timer = new DateTime.now().millisecondsSinceEpoch;
}


void endTimer()
{
  int now = new DateTime.now().millisecondsSinceEpoch;
  _timer = now - _timer;;
}


void reportTimer()
{
  double millis = _timer / 1000.0;
  window.alert(millis.toString());
}

void doOSG()
{  
     //var canvas = document.getElementById( 'View' );
     var canvas = querySelector("#View");
  
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
  
     var tempModelMap = getModel();
     startTimer();
     var tempModelJson = new JsObject.jsify(tempModelMap);
     endTimer();
     var t = new DateTime.now();
     var tempData = osgDB.callMethod("parseSceneGraph", [tempModelJson]);
     
     rotate.callMethod("addChild", [tempData]);
     
     //viewer.setSceneData( rotate );
     viewer.callMethod("setSceneData", [rotate]);
     
     //viewer.run();
     viewer.callMethod("run", []);
     
     //reportTimer();
     
     return;
}


void tapHandler1(Event e)
{ 
  var elem = querySelector("#dialog1");
  assert(elem is CoreOverlay);
  elem.open();
}

void tapHandler2(Event e)
{ 
  var elem = querySelector("#dialog2");
  assert(elem is CoreOverlay);
  elem.open();
}
void tapHandler3(Event e)
{ 
  var elem = querySelector("#dialog3");
  assert(elem is CoreOverlay);
  elem.open();
}

void main()
{
  initPolymer().run(() {
    
    // Code that doesn't need to wait.

    
    Polymer.onReady.then((_) {
      // Code that executes after elements have been upgraded.

      var subscription1 = querySelector("#button1").onClick.listen((event) => tapHandler1(event));
      var subscription2 = querySelector("#button2").onClick.listen((event) => tapHandler2(event));
      var subscription3 = querySelector("#button3").onClick.listen((event) => tapHandler3(event));
      
      doOSG();
    });
  });
}
