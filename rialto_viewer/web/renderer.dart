// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class Renderer {
    // public
    double _mouseGeoX = 0.0;
    double _mouseGeoY = 0.0;
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

    RenderablePointCloudSet _renderSource;

    Vector3 _cameraEyePoint;
    Vector3 _cameraTargetPoint;
    Vector3 _cameraUpVector;
    AxesObject _axesObject;
    Object3D _bboxObject;

    Matrix4 modelToWorld;

    Renderer(RenderablePointCloudSet rpcSet) {
        _scene = null;
        _projector = new Projector();

        _webglRenderer = new WebGLRenderer();
        _webglRenderer.setSize(window.innerWidth, window.innerHeight);

        var parentElement = Hub.root.renderPanel.shadowRoot.querySelector("#container");
        assert(parentElement != null);
        parentElement.children.add(_webglRenderer.domElement);

        Hub.root.eventRegistry.subscribeMouseMove(_updateMouseLocalCoords);
        Hub.root.eventRegistry.subscribeWindowResize(_onMyWindowResize);
        Hub.root.eventRegistry.subscribeDisplayAxes(_displayAxesHandler);
        Hub.root.eventRegistry.subscribeDisplayBbox(_displayBboxHandler);
        Hub.root.eventRegistry.subscribeUpdateRenderer((_) => update());

        _renderSource = rpcSet;

        modelToWorld = new Matrix4.identity();

        _canvas = _webglRenderer.domElement;
    }

    Element get canvas => _canvas;


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

    void update() {

        _scene = new Scene();

        // model space ...(xmin,ymin,zmin)..(xmax,ymax,zmax)...
        // world space ...(0,0)..(xlen,ylen)...
        //
        // min point of the model becomes the origin of world space

        var theMin = _renderSource.min;
        var theLen = _renderSource.len;
        if (_renderSource.length == 0)
        {
            theMin = new Vector3.zero();
            theLen = new Vector3(100.0, 100.0, 25.0);
        }

        modelToWorld = new Matrix4.identity();
        modelToWorld.translate(-theMin);

        {
            for (var rpc in _renderSource.renderablePointClouds)
            {
                var obj = rpc.getParticleSystem();
                obj.visible = rpc.visible;
                obj.applyMatrix(modelToWorld);
                _scene.add(obj);
            }
        }

        {
            // bbox model space is (0,0,0)..(100,100,100)
            _bboxObject = new BboxObject();
            Vector3 a = new Vector3(100.0, 100.0, 100.0);
            Vector3 b = theLen.clone();
            Vector3 c = b.divide(a);
            var bboxModelToWorld = new Matrix4.identity().scale(c);
            _bboxObject.applyMatrix(bboxModelToWorld);

            if (_showBbox) _scene.add(_bboxObject);
        }

        {
            // axes model space is (0,0,0)..(100,100,100)
            _axesObject = new AxesObject();
            Vector3 a = new Vector3(100.0, 100.0, 100.0);
            Vector3 b = theLen.clone();
            Vector3 c = b.divide(a).scale(1.0 / 4.0);
            var axesModelToWorld = new Matrix4.identity().scale(c);
            _axesObject.applyMatrix(axesModelToWorld);

            if (_showAxes) _scene.add(_axesObject);
        }


        {
            // camera positions are computed in geo space, but maintained in world space
            _cameraEyePoint = RenderUtils.getCameraPointEye(_renderSource);
            _cameraTargetPoint = RenderUtils.getCameraPointTarget(_renderSource);

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


    void _displayAxesHandler(BoolData data) {
        final bool on = data.v;
        if (_axesObject == null) return;

        if (on) {
            _scene.add(_axesObject);
        } else {
            _scene.remove(_axesObject);
        }
        _showAxes = on;
    }

    void _displayBboxHandler(BoolData data) {
        final bool on = data.v;
        if (_bboxObject == null) return;

        if (on) {
            _scene.add(_bboxObject);
        } else {
            _scene.remove(_bboxObject);
        }
        _showBbox = on;
    }


    void _updateMouseLocalCoords(MouseMoveData data) {
        final int newX = data.newX;
        final int newY = data.newY;

        // event.client.x,y is from upper left (0,0) of entire browser window

        // x,y is from upper left (0,0) of the canvas
        var x = newX - _canvasOffsetX;
        var y = newY - _canvasOffsetY;

        //print("screen: $x $y");

        // ncdX,Y is from lower left (-1,-1) to upper right (+1,+1) of the canvas
        _ndcMouseX = (x / _canvasWidth) * 2 - 1;
        _ndcMouseY = -(y / _canvasHeight) * 2 + 1;

        assert(_ndcMouseX > -1.01 && _ndcMouseX < 1.01);
        assert(_ndcMouseY > -1.01 && _ndcMouseY < 1.01);

        //print("ncd: $_ndcMouseX $_ndcMouseY");
    }


    void _onMyWindowResize(WindowResizeData data) {
        final w = window.innerWidth ;
        final h = window.innerHeight;
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
    Vector3 VectorAtZ(Vector3 origin, Vector3 direction, double z) {
        var o = origin.clone();
        var d = direction.clone();

        if (d.z < 0.001 && d.z > -0.001) {
            if (d.z < 0.0) {
                d.z = -0.001;
            } else {
                d.z = 0.001;
            }
        }

        var t = z - o.z;
        if (t < 0.001 && t > -0.001) {
            if (t < 0.0) {
                t = -0.001;
            } else {
                t = 0.001;
            }
        }

        var k = t / d.z;

        var vec = o + d * k;

        return vec;
    }

    Line _line1;
    void _updateMouseWorldCoords() {
        var vector = new Vector3(_ndcMouseX, _ndcMouseY, 0.5);

        Ray ray = _projector.pickingRay(vector.clone(), _camera);

        if (_line1 != null) _scene.remove(_line1);

        var q = VectorAtZ(ray.origin, ray.direction, 0.0);

        Matrix4 inv = modelToWorld.clone();
        inv.copyInverse(inv);

        var qq = q.clone();
        qq.applyProjection(inv);
        //print("WORLD ${q.x.toStringAsFixed(0)} ${q.y.toStringAsFixed(0)} ${q.z.toStringAsFixed(0)} - GEO ${qq.x.toStringAsFixed(0)} ${qq.y.toStringAsFixed(0)} ${qq.z.toStringAsFixed(0)}");

        /*
        var gline = new Geometry()
                ..vertices.add(new Vector3(0.0, 0.0, 0.0))
                ..vertices.add(q);
        _line1 = new Line(gline, new LineBasicMaterial(color: 0x0000ff));
        _scene.add(_line1);

        List<Intersect> l = ray.intersectObject(_scene, recursive:true);
        if (l.length > 0) {
            l.forEach((i) => print(i.object.name));
        }
        */

        _mouseGeoX = qq.x;
        _mouseGeoY = qq.y;

        Hub.root.eventRegistry.fireMouseGeoCoord(new GeoCoordsData(_mouseGeoX, _mouseGeoY));
    }
}
