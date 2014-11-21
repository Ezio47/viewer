library renderer;

import 'dart:html';
import 'dart:math' as Math;
import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart' hide Ray;
import 'package:three/extras/controls/trackball_controls.dart';
import 'render_source.dart';
import 'render_utils.dart';
import 'axes_object.dart';
import 'bbox_object.dart';


class Renderer {
    // public
    double mouseX = 0.0,
            mouseY = 0.0;
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
    double _ndcMouseX = 0.0,
            _ndcMouseY = 0.0; // [-1..+1]

    RenderSource _renderTarget;

    Vector3 _cameraEyePoint;
    Vector3 _cameraTargetPoint;
    Vector3 _cameraUpVector;
    AxesObject _axesObject;
    Object3D _bboxObject;

    // vertically, the two tool bars plus the status bar add up to 159
    //   toolbar(63+1) + toolbar(63+1) + statusbar(14+5+5+1) + mainbody_padding(6) = 159
    // horizontally, the sidebar adds up to 261
    //   sidebar(244+1+10) + mainbody_padding(6) = 261
    // but for some reason, I still get vertical scrollbars and/or not enough
    //   main body padding unless I add a little bit
    static const int _restOfWindowY = 159 + 3;
    static const int _restOfWindowX = 261 + 1;


    Renderer(var canvas) {
        assert(canvas != null);
        _canvas = canvas;
    }


    void init() {
        _scene = new Scene();
        _projector = new Projector();

        _webglRenderer = new WebGLRenderer();
        _webglRenderer.setSize(window.innerWidth - _restOfWindowX, window.innerHeight - _restOfWindowY);
        _canvas.children.add(_webglRenderer.domElement);

        _canvas.onMouseMove.listen(_updateMouseLocalCoords);
        window.onResize.listen(_onMyWindowResize);
    }


    void goHome() {
        _camera.position.setFrom(_cameraEyePoint);
        _camera.up.setFrom(_cameraUpVector);
        _camera.lookAt(_cameraTargetPoint);
    }

    int get _canvasWidth {
        return _canvas.clientWidth;
    }
    int get _canvasHeight {
        return _canvas.clientHeight;
    }
    int get _canvasOffsetX {
        return _canvas.documentOffset.x;
    }
    int get _canvasOffsetY {
        return _canvas.documentOffset.y;
    }

    void _addCamera() {
        var w = _canvasWidth;
        var h = _canvasHeight;
        final double aspect = w.toDouble() / h.toDouble();
        _camera = new PerspectiveCamera(50.0, aspect, 0.01, 200000.0);

        _scene.add(_camera);
    }

    void _addCameraControls() {
        _cameraControls = new TrackballControls(_camera, _webglRenderer.domElement);
        _cameraControls.zoomSpeed = 0.25;

        //_cameraControls.rotateSpeed = 1.0;
        //_cameraControls.panSpeed = 0.8;
        //_cameraControls.noZoom = false;
        //_cameraControls.noPan = false;
        //_cameraControls.staticMoving = true;
        //_cameraControls.dynamicDampingFactor = 0.3;
    }

    void setSource(RenderSource renderTarget) {
        _renderTarget = renderTarget;

        // model space ...(xmin,ymin,zmin)..(xmax,ymax,zmax)...
        // world space ...(0,0)..(xlen,ylen)...
        //
        // min point of the model becomes the origin of world space

        var modelToWorld = new Matrix4.identity();
        modelToWorld.translate(-renderTarget.min);

        {
            _particleSystem = RenderUtils.drawPoints(renderTarget);
            _particleSystem.applyMatrix(modelToWorld);
            _scene.add(_particleSystem);
        }

        {
            // bbox model space is (0,0,0)..(100,100,100)
            _bboxObject = new BboxObject();
            Vector3 a = new Vector3(100.0, 100.0, 100.0);
            Vector3 b = renderTarget.len.clone();
            Vector3 c = b.divide(a);
            var bboxModelToWorld = new Matrix4.identity().scale(c);
            _bboxObject.applyMatrix(bboxModelToWorld);

            if (_showBbox) _scene.add(_bboxObject);
        }

        {
            // axes model space is (0,0,0)..(100,100,100)
            _axesObject = new AxesObject();
            Vector3 a = new Vector3(100.0, 100.0, 100.0);
            Vector3 b = renderTarget.len.clone();
            Vector3 c = b.divide(a).scale(1.0 / 4.0);
            var axesModelToWorld = new Matrix4.identity().scale(c);
            _axesObject.applyMatrix(axesModelToWorld);

            if (_showAxes) _scene.add(_axesObject);
        }

        {
            // when we set the cloud, we need to set the camera relative to it
            // position is returned in model space
            _cameraEyePoint = RenderUtils.getCameraPointEye(renderTarget);
            _cameraTargetPoint = RenderUtils.getCameraPointTarget(renderTarget);

            // move position to world space
            _cameraEyePoint.applyProjection(modelToWorld);
            _cameraTargetPoint.applyProjection(modelToWorld);
            _cameraUpVector = new Vector3(0.0, 0.0, 1.0);

            _addCamera();
            goHome();
            _addCameraControls();
            _cameraControls.target = _cameraTargetPoint;
        }

        goHome();
    }


    void unsetSource() {
        _renderTarget = null;

        if (_particleSystem != null) {
            _scene.remove(_particleSystem);
            _particleSystem = null;
        }

        if (_axesObject != null) {
            _scene.remove(_axesObject);
        }

        if (_bboxObject != null) {
            _scene.remove(_bboxObject);
        }
    }


    void toggleAxesDisplay(bool on) {
        if (_axesObject == null) return;

        if (on) {
            _scene.add(_axesObject);
        } else {
            _scene.remove(_axesObject);
        }
        _showAxes = on;
    }


    void toggleBboxDisplay(bool on) {
        if (_bboxObject == null) return;

        if (on) {
            _scene.add(_bboxObject);
        } else {
            _scene.remove(_bboxObject);
        }
        _showBbox = on;
    }


    void _updateMouseLocalCoords(event) {
        event.preventDefault();

        // event.client.x,y is from upper left (0,0) of entire browser window

        // x,y is from upper left (0,0) of the canvas
        var x = event.client.x - _canvasOffsetX;
        var y = event.client.y - _canvasOffsetY;

        //print("screen: $x $y");

        // ncdX,Y is from lower left (-1,-1) to upper right (+1,+1) of the canvas
        _ndcMouseX = (x / _canvasWidth) * 2 - 1;
        _ndcMouseY = -(y / _canvasHeight) * 2 + 1;

        assert(_ndcMouseX > -1.01 && _ndcMouseX < 1.01);
        assert(_ndcMouseY > -1.01 && _ndcMouseY < 1.01);

        //print("ncd: $_ndcMouseX $_ndcMouseY");
    }


    _onMyWindowResize(event) {
        var w = window.innerWidth - _restOfWindowX;
        var h = window.innerHeight - _restOfWindowY;
        _webglRenderer.setSize(w, h);

        final double aspect = w.toDouble() / h.toDouble();
        _camera.aspect = aspect;

        _camera.lookAt(_scene.position);
    }


    void animate(num time) {
        window.requestAnimationFrame(animate);
        _render();
    }


    void _render() {
        if (_camera == null) return;

        if (_cameraControls != null) {
            _cameraControls.update();
        }

        _updateMouseWorldCoords();

        _webglRenderer.render(_scene, _camera);
    }


    void _updateMouseWorldCoords() {

        var vector = new Vector3(_ndcMouseX, _ndcMouseY, 0.0);
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
