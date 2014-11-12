library renderer;

import 'dart:html';
//import 'dart:math' as Math;
import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart' hide Ray;
import 'package:three/extras/controls/trackball_controls.dart';
import 'point_cloud.dart';
import 'render_utils.dart';
import 'utils.dart';


class Renderer
{
  // public
  double mouseX = 0.0, mouseY = 0.0;
  bool _showAxes = false;
  bool _showBbox = false;

  // private
  Camera _camera;
  Scene _scene;
  WebGLRenderer _webglRenderer;
  var _cameraControls;
  Projector _projector;
  Element _canvas;
  ParticleSystem _particleSystem;
  Line _myline;
  double _ndcMouseX = 0.0, _ndcMouseY = 0.0;

  List<Line> _axes;
  List<Line> _bbox;


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

    _canvas.onMouseMove.listen(_updateMouseLocalCoords);
    window.onResize.listen(_onMyWindowResize);
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


  void setCloud(PointCloud cloud)
  {
    _particleSystem = RenderUtils.drawPoints(cloud);
    _scene.add(_particleSystem);

    _axes = RenderUtils.drawAxes(cloud.low, cloud.high);
    if (_showAxes)
    {
      _axes.forEach((l) => _scene.add(l));
    }

    _bbox = RenderUtils.drawBbox(cloud.low, cloud.high);
    if (_showBbox)
    {
      _bbox.forEach((l) => _scene.add(l));
    }
  }


  void unsetCloud()
  {
    _scene.remove(_particleSystem);
    _axes.forEach((l) => _scene.remove(l));
    _bbox.forEach((l) => _scene.remove(l));
  }


  void toggleAxesDisplay(bool on)
  {
    if (on)
    {
      _axes.forEach((l) => _scene.add(l));
    }
    else
    {
      _axes.forEach((l) => _scene.remove(l));
    }
    _showAxes = on;
  }


  void toggleBboxDisplay(bool on)
  {
    if (on)
    {
      _bbox.forEach((l) => _scene.add(l));
    }
    else
    {
      _bbox.forEach((l) => _scene.remove(l));
    }
    _showBbox = on;
  }


  void _updateMouseLocalCoords( event )
  {
    event.preventDefault();

    var x = event.client.x - _canvas.documentOffset.x;
    var y = event.client.y - _canvas.documentOffset.y;

    //print ("mouse: $x $y");

    _ndcMouseX = ( x / window.innerWidth ) * 2 - 1;
    _ndcMouseY = - ( y / window.innerHeight ) * 2 + 1;
  }


  _onMyWindowResize(event)
  {
    _webglRenderer.setSize( window.innerWidth, window.innerHeight );
  }


  void animate(num time)
  {
    window.requestAnimationFrame(animate);
    _render();
  }


  void _render()
  {
    if (_cameraControls != null)
    {
      _cameraControls.update();
    }

    _updateMouseWorldCoords();

    _webglRenderer.render( _scene, _camera );
  }


  void _updateMouseWorldCoords()
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
}
