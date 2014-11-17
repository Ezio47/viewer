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
  PerspectiveCamera _camera;
  Scene _scene;
  WebGLRenderer _webglRenderer;
  var _cameraControls;
  Projector _projector;
  Element _canvas;
  ParticleSystem _particleSystem;
  Line _myline;
  double _ndcMouseX = 0.0, _ndcMouseY = 0.0;  // [-1..+1]

  PointCloud _currentCloud;

  Vector3 _cameraHomePosition = new Vector3(0.0, 0.0, 0.0);
  Vector3 _cameraUpPosition = new Vector3(0.0, 1.0, 0.0);
  List<Line> _axes;
  List<Line> _bbox;

  // vertically, the two tool bars plus the status bar add up to 159
  //   toolbar(63+1) + toolbar(63+1) + statusbar(14+5+5+1) + mainbody_padding(6) = 159
  // horizontally, the sidebar adds up to 261
  //   sidebar(244+1+10) + mainbody_padding(6) = 261
  // but for some reason, I still get vertical scrollbars and/or not enough
  //   main body padding unless I add a little bit
  static const int _restOfWindowY = 159 + 3;
  static const int _restOfWindowX = 261 + 1;


  Renderer(var canvas)
  {
    assert(canvas != null);
    _canvas = canvas;
  }


  void init()
  {
    _scene = new Scene();
    _projector = new Projector();

    _webglRenderer = new WebGLRenderer();
    _webglRenderer.setSize(window.innerWidth - _restOfWindowX, window.innerHeight - _restOfWindowY);
    _canvas.children.add(_webglRenderer.domElement);

    _addCamera();
    _addCameraControls();

    _canvas.onMouseMove.listen(_updateMouseLocalCoords);
    window.onResize.listen(_onMyWindowResize);
  }


  void goHome()
  {
    _camera.position.setFrom(_cameraHomePosition);
    _camera.up.setFrom(_cameraUpPosition);
  }


  void _addCameraControls()
  {
    _cameraControls = new TrackballControls(_camera, _webglRenderer.domElement);
    _cameraControls.zoomSpeed = 0.25;

    //_cameraControls.target = new Vector3(0.0, 2.0, 0.0);
    //_cameraControls.rotateSpeed = 1.0;
    //_cameraControls.panSpeed = 0.8;
    //_cameraControls.noZoom = false;
    //_cameraControls.noPan = false;
    //_cameraControls.staticMoving = true;
    //_cameraControls.dynamicDampingFactor = 0.3;
  }


  void _addCamera()
  {
    var w = window.innerWidth - _canvas.documentOffset.x;
    var h = window.innerHeight - _canvas.documentOffset.y;
    final double aspect = w.toDouble() / h.toDouble();
    _camera = new PerspectiveCamera(60.0, aspect, 0.1, 20000.0);

    _scene.add(_camera);
  }


  void setCloud(PointCloud cloud)
  {
    _currentCloud = cloud;

    _particleSystem = RenderUtils.drawPoints(cloud);
    _scene.add(_particleSystem);

    // when we set the cloud, we need to set the camera relative to it
    _cameraHomePosition = RenderUtils.getDefaultCameraPosition(cloud);
    goHome();

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


  PointCloud unsetCloud()
  {
    var oldCloud = _currentCloud;
    _currentCloud = null;

    _scene.remove(_particleSystem);
    _axes.forEach((l) => _scene.remove(l));
    _bbox.forEach((l) => _scene.remove(l));

    _cameraHomePosition = new Vector3(0.0, 0.0, 0.0);

    return oldCloud;
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

    _ndcMouseX = ( x / window.innerWidth ) * 2 - 1;
    _ndcMouseY = - ( y / window.innerHeight ) * 2 + 1;
  }


  _onMyWindowResize(event)
  {
    var w = window.innerWidth - _restOfWindowX;
    var h = window.innerHeight - _restOfWindowY;
    _webglRenderer.setSize(w, h);

    final double aspect = w.toDouble() / h.toDouble();
    _camera.aspect = aspect;

    _camera.lookAt(_scene.position);
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
    //_camera.lookAt(_scene.position);

    var vector = new Vector3(_ndcMouseX, _ndcMouseY, 1.0);
    _projector.unprojectVector(vector, _camera);
    var x = vector.x;
    var y = vector.y;
    var z = vector.z;

    //mouseX = _ndcMouseX;
    //mouseY = _ndcMouseY;
    mouseX = x;
    mouseY = y;
  }
}
