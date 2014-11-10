library webgl;

import 'dart:html';
import 'dart:math' as Math;
import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart' hide Ray;
import 'package:three/extras/controls/trackball_controls.dart';
import 'package:three/extras/image_utils.dart';


class webgl
{
  double mouseX = 0.0, mouseY = 0.0;
  
Element container;

Camera camera;
Scene scene;
WebGLRenderer renderer;

var particleSystem;

var cameraControls;
Projector projector;
var rnd = new Math.Random();
var _canvas;

//void main() {
//  init();
//  animate(0);
//}

void init(canvas) {
_canvas = canvas;
  container = canvas;
  assert(container != null);

  //camera = new PerspectiveCamera( 90.0, window.innerWidth / window.innerHeight, 1.0, 10000.0 );
  camera = new OrthographicCamera(-2500.0, 2500.0, 2500.0, -2500.0, 0.1, 10000.0);
  
  camera.position.setValues(0.0, 0.0, 5000.0);
  camera.lookAt(new Vector3(0.0, 0.0, 0.0));

  scene = new Scene();

  scene.add(camera);
  
  projector = new Projector();
  
  var particles =  100000;

  var positions = new GeometryAttribute.float32(particles * 3, 3);
  var colors     = new GeometryAttribute.float32(particles * 3, 3);

  BufferGeometry geometry = new BufferGeometry();
  geometry.attributes = {
     "position" : positions,
     "color"    : colors
  };

  var color = new Color();

  var n = 1000.0, n2 = n / 2.0; // particles spread in the cube

  for ( var i = 0; i < positions.array.length; i += 3 ) {

    // positions
    var x = rnd.nextDouble() * n - n2;   // -500..+500
    var y = rnd.nextDouble() * n - n2;
    var z = rnd.nextDouble() * n - n2;
    assert(x>=-500.0 && y>=-500.0 && z>=-500.0);
    assert(x<=500.0 && y<=500.0 && z<=500.0);
    //print("$x $y $z");
    
    positions.array[ i     ] = x;
    positions.array[ i + 1 ] = y;
    positions.array[ i + 2 ] = z;

    // colors
    var vx = ( x / n ) + 0.5;
    var vy = ( y / n ) + 0.5;
    var vz = ( z / n ) + 0.5;

    color.setRGB( vx, vy, vz );

    //colors.array[ i ]     = color.r;
    //colors.array[ i + 1 ] = color.g;
    //colors.array[ i + 2 ] = color.b;
    
    if (x < 0.0 && y < 0.0 && z < 0.0)
    {
      // red at -5,-5,-5
      colors.array[i] = 1.0;
      colors.array[i+1] = 0.0;
      colors.array[i+2] = 0.0;
      //print("$x $y $z");
    }
    else if (x > 0.0 && y > 0.0 && z> 0.0)
    {
      // blue at +5,+5,+5
      colors.array[i] = 0.0;
      colors.array[i+1] = 0.0;
      colors.array[i+2] = 1.0;
    }
    else
    {
      colors.array[i] = 0.0;
      colors.array[i+1] = 0.0;
      colors.array[i+2] = 0.0;
    }
    
  }

  geometry.computeBoundingSphere();
  var material = new ParticleBasicMaterial( size: 5, vertexColors: 2 );

  particleSystem = new ParticleSystem( geometry, material );
  scene.add( particleSystem );

  {
    var material = new LineBasicMaterial(color:0xff0000);
    var geometry = new Geometry();
    geometry.vertices.add(new Vector3( -500.0, -500.0, -500.0 ));
    geometry.vertices.add(new Vector3( 500.0, -500.0, -500.0 ));
    var line = new Line( geometry, material );
    scene.add( line );
  }
  {
    var material = new LineBasicMaterial(color:0x00ff00);
    var geometry = new Geometry();
    geometry.vertices.add(new Vector3( -500.0, -500.0, -500.0 ));
    geometry.vertices.add(new Vector3( -500.0, 500.0, -500.0 ));
    var line = new Line( geometry, material );
    scene.add( line );
  }
  {
    var material = new LineBasicMaterial(color:0x0000ff);
    var geometry = new Geometry();
    geometry.vertices.add(new Vector3( -500.0, -500.0, -500.0 ));
    geometry.vertices.add(new Vector3( -500.0, -500.0, 500.0 ));
    var line = new Line( geometry, material );
    scene.add( line );
  }
    /*
    var numLines = 2;
    var positions = new GeometryAttribute.float32(numLines * 3, 3);
    var colors     = new GeometryAttribute.float32(numLines * 3, 3);
    
    BufferGeometry geometry = new BufferGeometry();
    geometry.attributes = {
       "position" : positions,
       "color"    : colors
    };

    colors.array[0] = 0.5;
    colors.array[1] = 0.5;
    colors.array[2] = 0.5;
    colors.array[3] = 0.5;
    colors.array[4] = 0.5;
    colors.array[5] = 0.5;
    
    positions.array[0] = -500.0;
    positions.array[1] = -500.0;
    positions.array[2] = -500.0;
    
    positions.array[3] = 500.0;
    positions.array[4] = 500.0;
    positions.array[5] = 500.0;

    var line = new Line(geometry);
    
    scene.add(line);*/
  
  
  
  
  renderer = new WebGLRenderer()
  ..setSize( window.innerWidth, window.innerHeight );

  container.children.add( renderer.domElement );
  
  cameraControls  = new TrackballControls(camera, renderer.domElement);
  cameraControls.target = new Vector3(0.0, 2.0, 0.0);
  cameraControls.rotateSpeed = 1.0;
  cameraControls.zoomSpeed = 1.2;
  cameraControls.panSpeed = 0.8;
  cameraControls.noZoom = false;
  cameraControls.noPan = false;

  cameraControls.staticMoving = true;
  cameraControls.dynamicDampingFactor = 0.3;

  container.onMouseMove.listen(onDocumentMouseMove);
  
  window.onResize.listen( onWindowResize );
}


onDocumentMouseMove( event ) {

  event.preventDefault();

  var x = event.client.x - _canvas.documentOffset.x;
  var y = event.client.y - _canvas.documentOffset.y;
 
  //print ("mouse: $x $y");
    
  mouseX = ( x / window.innerWidth ) * 2 - 1;
  mouseY = - ( y / window.innerHeight ) * 2 + 1;
 
}


onWindowResize(event) {
  //camera
//  ..aspect = window.innerWidth / window.innerHeight
  //..updateProjectionMatrix();

  renderer.setSize( window.innerWidth, window.innerHeight );
}

animate(num time) {
  window.requestAnimationFrame( animate );
  render();
}

Mesh INTERSECTED;
num currentHex;
Line myline;

render() {
  //print ("mouse: $mouseX $mouseY");
  //particleSystem.rotation.x += 0.0025;
  //particleSystem.rotation.y += 0.005;

  if (cameraControls != null)
  {
    cameraControls.update();
    
    /// // limit camera position to avoid showing shadow on backface
    /// camera.position.y = Math.max(camera.position.y, 3.0);
  }

  camera.lookAt( scene.position );
  var xx = scene.position.x;
  var yy = scene.position.y;
  var zz = scene.position.z;
  assert(xx==0.0 && yy==0.0 && zz==0.0);
  //print("scene: $xx $yy $zz");
  
  xx = camera.position.x;
  yy = camera.position.y;
  zz = camera.position.z;
//  assert(xx==0.0 && yy==0.0 && zz==5000.0);
  //print("camera: $xx $yy $zz");
  
  var vector = new Vector3( mouseX, mouseY, 0.0 );
  projector.unprojectVector( vector, camera );
  xx = vector.x;
  yy = vector.y;
  zz = vector.z;
  //print("unproject: $xx $yy $zz");

  var ray = new Ray( camera.position, vector.sub( camera.position ).normalize() );
  xx = ray.origin.x;
  yy = ray.origin.y;
  zz = ray.origin.z;
  var xxx = ray.direction.x;
  var yyy = ray.direction.y;
  var zzz = ray.direction.z;
  //print("ray: $xx $yy $zz / $xxx $yyy $zzz");
   
  if (myline != null)
  {
    scene.remove(myline);
  }
  {
     var material = new LineBasicMaterial(color:0x888888);
     var geometry = new Geometry();
     //geometry.vertices.add(new Vector3( xx,yy,zz ));
     geometry.vertices.add(new Vector3( xx-2000*xxx, yy-2000*yyy, zz-2000*zzz ));
     geometry.vertices.add(new Vector3( xx+2000*xxx, yy+2000*yyy, zz+2000*zzz ));
     myline = new Line( geometry, material );
     scene.add( myline );
   }
  
  renderer.render( scene, camera );

}
}
