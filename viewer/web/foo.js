function hittest(viewer)
{
  var ev_clientX = 100;
  var ev_clientY = 100;
  var canvas = document.getElementById( 'View' );
  
  var ratioX = canvas.width / canvas.clientWidth;
  var ratioY = canvas.height / canvas.clientHeight;

  var hits = viewer.computeIntersections( ev_clientX * ratioX, (canvas.clientHeight - ev_clientY) * ratioY );
   
  hits.sort( function( a, b ) {
    return a.ratio - b.ratio;
  } );

  if ( hits.length > 0 ) {
    var point = hits[ 0 ].point;
    var ptFixed = [ point[ 0 ].toFixed( 2 ), point[ 1 ].toFixed( 2 ), point[ 2 ].toFixed( 2 ) ];

    var pt = projectToScreen( viewer.getCamera(), hits[ 0 ] );

    var ptx = parseInt( pt[ 0 ], 10 ) / ratioX;
    var pty = parseInt( canvas.height - pt[ 1 ], 10 ) / ratioY;
//    var d = document.getElementById( 'picking' );
//    d.innerText = 'x: ' + ptx + ' ' + 'y: ' + pty + '\n' + ptFixed;
//    d.style.transform = 'translate3d(' + ptx + 'px,' + pty + 'px,0)';
  }
  return ptx;
}

 window.myosg = { "hittest": hittest };

 