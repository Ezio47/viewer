library renderer;

import 'dart:html';
//import 'dart:math' as Math;
import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart' hide Ray;
import 'package:three/extras/controls/trackball_controls.dart';
import 'point_cloud.dart';


class Renderer
{
  // public
  double mouseX = 0.0, mouseY = 0.0;
  bool showAxes = false;

  // private
  Camera _camera;
  Scene _scene;
  WebGLRenderer _webglRenderer;
  var _cameraControls;
  Projector _projector;
  Element _canvas;
  ParticleSystem _particleSystem;
  List<Line> _axes = new List();
  Line _myline;
  double _ndcMouseX = 0.0, _ndcMouseY = 0.0;


  Renderer(var canvas)
  {
    assert(canvas != null);
    _canvas = canvas;
  }


  void init()
  {
    _scene = new Scene();
    _projector = new Projector();

    _addCamera();

    _webglRenderer = new WebGLRenderer();
    _webglRenderer.setSize(window.innerWidth, window.innerHeight);
    _canvas.children.add(_webglRenderer.domElement);

    _addCameraControls();

    _canvas.onMouseMove.listen(onMyMouseMove);
    window.onResize.listen(onMyWindowResize);
  }


  void _addCameraControls()
  {
    _cameraControls = new TrackballControls(_camera, _webglRenderer.domElement);
    _cameraControls.target = new Vector3(0.0, 2.0, 0.0);
    _cameraControls.rotateSpeed = 1.0;
    _cameraControls.zoomSpeed = 1.2;
    _cameraControls.panSpeed = 0.8;
    _cameraControls.noZoom = false;
    _cameraControls.noPan = false;

    _cameraControls.staticMoving = true;
    _cameraControls.dynamicDampingFactor = 0.3;
  }


  void _addCamera()
  {
    //camera = new PerspectiveCamera( 90.0, window.innerWidth / window.innerHeight, 1.0, 10000.0 );
    _camera = new OrthographicCamera(-2500.0, 2500.0, 2500.0, -2500.0, 0.1, 10000.0);

    _camera.position.setValues(0.0, 0.0, 5000.0);
    _camera.lookAt(new Vector3(0.0, 0.0, 0.0));

    _scene.add(_camera);
  }


  static GeometryAttribute _clone(GeometryAttribute src)
  {
    int count = src.numItems;

    var dst = new GeometryAttribute.float32(count, 3);

    for (int i=0; i<count; i++)
    {
      dst.array[i] = src.array[i];
    }

    return dst;
  }

  void addCloud(PointCloud cloud)
  {
    var positions = cloud.map["positions"];
    var colors    = cloud.map["colors"];
    assert(positions != null);
    assert(colors != null);

    // the underlying system wants to take ownership of these arrays, so we'll
    // pass them copies
    BufferGeometry geometry = new BufferGeometry();
    geometry.attributes = {
       "position" : _clone(positions),
       "color"    : _clone(colors)
    };

    geometry.computeBoundingSphere();
    var material = new ParticleBasicMaterial( size: 5, vertexColors: 2 );

    _particleSystem = new ParticleSystem( geometry, material );
    _scene.add( _particleSystem );

    createAxes(cloud);
    if (showAxes)
    {
      _scene.add(_axes[0]);
      _scene.add(_axes[1]);
      _scene.add(_axes[2]);
    }
  }


  void createAxes(var cloud)
  {
    _axes.clear();

    var material;
    var geometry;
    var line;

    material = new LineBasicMaterial(color:0xff0000);
    geometry = new Geometry();
    geometry.vertices.add(new Vector3( cloud.minx, cloud.miny, cloud.minz ));
    geometry.vertices.add(new Vector3( cloud.maxx, cloud.miny, cloud.minz ));
    line = new Line( geometry, material );
    _axes.add(line);

    material = new LineBasicMaterial(color:0x00ff00);
    geometry = new Geometry();
    geometry.vertices.add(new Vector3( cloud.minx, cloud.miny, cloud.minz ));
    geometry.vertices.add(new Vector3( cloud.minx, cloud.maxy, cloud.minz ));
    line = new Line( geometry, material );
    _axes.add(line);

    material = new LineBasicMaterial(color:0x0000ff);
    geometry = new Geometry();
    geometry.vertices.add(new Vector3( cloud.minx, cloud.miny, cloud.minz ));
    geometry.vertices.add(new Vector3( cloud.minx, cloud.miny, cloud.maxz ));
    line = new Line( geometry, material );
    _axes.add(line);
  }


  void removeCloud()
  {
    _scene.remove(_particleSystem);
    _scene.remove(_axes[0]);
    _scene.remove(_axes[1]);
    _scene.remove(_axes[2]);
  }


  void addAxes()
  {
    _scene.add(_axes[0]);
    _scene.add(_axes[1]);
    _scene.add(_axes[2]);
  }


  void removeAxes()
  {
    _scene.remove(_axes[0]);
    _scene.remove(_axes[1]);
    _scene.remove(_axes[2]);
  }


  void onMyMouseMove( event )
  {
    event.preventDefault();

    var x = event.client.x - _canvas.documentOffset.x;
    var y = event.client.y - _canvas.documentOffset.y;

    //print ("mouse: $x $y");

    _ndcMouseX = ( x / window.innerWidth ) * 2 - 1;
    _ndcMouseY = - ( y / window.innerHeight ) * 2 + 1;

  }


  onMyWindowResize(event)
  {
    _webglRenderer.setSize( window.innerWidth, window.innerHeight );
  }


  void animate(num time)
  {
    window.requestAnimationFrame(animate);
    render();
  }


  void render()
  {
    if (_cameraControls != null)
    {
      _cameraControls.update();
    }

    updateMouse();

    //createRay();

    _webglRenderer.render( _scene, _camera );
  }


  void updateMouse()
  {
    _camera.lookAt( _scene.position );

    var vector = new Vector3( _ndcMouseX, _ndcMouseY, 0.0 );
    _projector.unprojectVector( vector, _camera );
    var xx = vector.x;
    var yy = vector.y;
    var zz = vector.z;

    mouseX = xx;
    mouseY = yy;
  }


  void createRay()
  {
    _camera.lookAt( _scene.position );

    var vector = new Vector3( _ndcMouseX, _ndcMouseY, 0.0 );
    _projector.unprojectVector( vector, _camera );

    var ray = new Ray( _camera.position, vector.sub( _camera.position ).normalize() );
    var xx = ray.origin.x;
    var yy = ray.origin.y;
    var zz = ray.origin.z;
    var xxx = ray.direction.x;
    var yyy = ray.direction.y;
    var zzz = ray.direction.z;

    if (_myline != null)
    {
      _scene.remove(_myline);
    }
    {
       var material = new LineBasicMaterial(color:0x888888);
       var geometry = new Geometry();
       //geometry.vertices.add(new Vector3( xx,yy,zz ));
       geometry.vertices.add(new Vector3( xx-2000*xxx, yy-2000*yyy, zz-2000*zzz ));
       geometry.vertices.add(new Vector3( xx+2000*xxx, yy+2000*yyy, zz+2000*zzz ));
       _myline = new Line( geometry, material );
       _scene.add( _myline );
     }
  }
}
