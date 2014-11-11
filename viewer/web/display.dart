library webgl;

import 'dart:html';
//import 'dart:math' as Math;
import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart' hide Ray;
import 'package:three/extras/controls/trackball_controls.dart';
import 'cloud_generator.dart';

class Display
{
  double ndc_mouseX = 0.0, ndc_mouseY = 0.0;
  double mouseX = 0.0, mouseY = 0.0;
  
  bool showAxes = false;
  
  Element container;

  Camera camera;
  Scene scene;
  WebGLRenderer renderer;
  
  var particleSystem;
  
  var cameraControls;
  Projector projector;

  var _canvas;
  
  List<Line> axes = new List();


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
  
    var map = CloudGenerator.makeNewCube(particles);
    var positions = map["positions"];
    var colors     = map["colors"];
    assert(positions != null);
    assert(colors != null);
  
    BufferGeometry geometry = new BufferGeometry();
    geometry.attributes = {
       "position" : positions,
       "color"    : colors
    };
  
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
      axes.add(line);
    }
    {
      var material = new LineBasicMaterial(color:0x00ff00);
      var geometry = new Geometry();
      geometry.vertices.add(new Vector3( -500.0, -500.0, -500.0 ));
      geometry.vertices.add(new Vector3( -500.0, 500.0, -500.0 ));
      var line = new Line( geometry, material );
      axes.add(line);
    }
    {
      var material = new LineBasicMaterial(color:0x0000ff);
      var geometry = new Geometry();
      geometry.vertices.add(new Vector3( -500.0, -500.0, -500.0 ));
      geometry.vertices.add(new Vector3( -500.0, -500.0, 500.0 ));
      var line = new Line( geometry, material );
      axes.add(line);
    }
    if (showAxes)
    {
      scene.add(axes[0]);
      scene.add(axes[1]);
      scene.add(axes[2]);
    }
    
    
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

  void addAxes()
  {
    scene.add(axes[0]);
    scene.add(axes[1]);
    scene.add(axes[2]);
  }
  
  void removeAxes()
  {
    scene.remove(axes[0]);
    scene.remove(axes[1]);
    scene.remove(axes[2]);
  }


  onDocumentMouseMove( event ) {
  
    event.preventDefault();
  
    var x = event.client.x - _canvas.documentOffset.x;
    var y = event.client.y - _canvas.documentOffset.y;
   
    //print ("mouse: $x $y");
      
    ndc_mouseX = ( x / window.innerWidth ) * 2 - 1;
    ndc_mouseY = - ( y / window.innerHeight ) * 2 + 1;
   
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
    
    var vector = new Vector3( ndc_mouseX, ndc_mouseY, 0.0 );
    projector.unprojectVector( vector, camera );
    xx = vector.x;
    yy = vector.y;
    zz = vector.z;
    //print("unproject: $xx $yy $zz");
  
    mouseX = xx;
    mouseY = yy;
    
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
