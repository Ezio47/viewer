function assert(condition, message) {
    if (!condition) {
        message = message || "Assertion failed";
        if (typeof Error !== "undefined") {
            throw new Error(message);
        }
        throw message; // Fallback
    }
}

function hittest()
{
  var canvas = document.getElementById( 'View' );
  
 
  var viewer = new osgViewer.Viewer( canvas );
  viewer.init();
  viewer.setSceneData( createScene( viewer, unifs ) );
  viewer.setupManipulator();
  viewer.run();

  canvas.addEventListener( 'mousemove', function( ev ) {
    var ratioX = canvas.width / canvas.clientWidth;
    var ratioY = canvas.height / canvas.clientHeight;
  
    var hits = viewer.computeIntersections( ev.clientX * ratioX, (canvas.clientHeight - ev.clientY) * ratioY );
  
    hits.sort( function( a, b ) {
        return a.ratio - b.ratio;
    } );
  
    if ( hits.length > 0 ) {
      var point = hits[ 0 ].point;
      var ptFixed = [ point[ 0 ].toFixed( 2 ), point[ 1 ].toFixed( 2 ), point[ 2 ].toFixed( 2 ) ];
  
  
      var pt = projectToScreen( viewer.getCamera(), hits[ 0 ] );
  
      var ptx = parseInt( pt[ 0 ], 10 ) / ratioX;
      var pty = parseInt( canvas.height - pt[ 1 ], 10 ) / ratioY;
      var d = document.getElementById( 'picking' );
      d.innerText = 'x: ' + ptx + ' ' + 'y: ' + pty + '\n' + ptFixed;
      d.style.transform = 'translate3d(' + ptx + 'px,' + pty + 'px,0)';
    }
  });
}    


function Go(canvas, json)
{
  OSG.globalify();
    
  // var canvas = document.getElementById( 'View' );
  assert(canvas != null);

  var osg = window.OSG.osg;
           
  viewer = new osgViewer.Viewer( canvas );
      
  viewer.init();
    
  viewer.setupManipulator();
     
  var rotate = new osg.MatrixTransform();
     
  osg.Matrix.makeRotate( -Math.PI * 0.5, 1, 0, 0, rotate.getMatrix() );
  
  Q.when( osgDB.parseSceneGraph( json ) ).then( function ( data ) {
      rotate.addChild( data );
  } );
 
  viewer.setSceneData( rotate );
     
  viewer.run();

  canvas.addEventListener( 'mousemove', function( ev ) {
    var ratioX = canvas.width / canvas.clientWidth;
    var ratioY = canvas.height / canvas.clientHeight;
  
    var cam = viewer.getCamera();
    console.log("View");
    console.log(cam.getViewMatrix());
    console.log("Proj");
    console.log(cam.getProjectionMatrix());
    console.log("Wind");
    console.log(cam.getViewport().computeWindowMatrix());
    console.log("V: %s, %s", ev.clientX * ratioX, (canvas.clientHeight - ev.clientY) * ratioY );
    
    
    {
       var mat = osg.Matrix.create();
       osg.Matrix.preMult( mat, cam.getViewport() ? cam.getViewport().computeWindowMatrix() : osg.Matrix.create() );
       osg.Matrix.preMult( mat, cam.getProjectionMatrix() );
       osg.Matrix.preMult( mat, cam.getViewMatrix() );
       /// // Node 0 in nodepath is the Camera of the Viewer, so we take next child
       /// osg.Matrix.preMult( mat, osg.computeLocalToWorld( hit.nodepath.slice( 1 ) ) );

       var pt = [ 0.0, 0.0, 0.0 ];
       var mypt = [ev.clientX * ratioX, (canvas.clientHeight - ev.clientY) * ratioY, 0.0];
       osg.Matrix.transformVec3( mat, mypt, pt );
       console.log(mat);
    }
    
    /*
    var hits = viewer.computeIntersections( ev.clientX * ratioX, (canvas.clientHeight - ev.clientY) * ratioY );
  
    hits.sort( function( a, b ) {
      return a.ratio - b.ratio;
    } );
  
    if (hits.length > 0)
    {
      console.log(hits);
    } */
     
  });
}


window['xxx'] = 5;  // access as: context['xxx'] 
window['yyy'] = { "hittest": hittest,
                  "Go": Go };

 