// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class Renderer {
    Hub _hub;

    CanvasElement _canvas;
    RenderingContext gl;
    GlProgram _glProgram;

    Matrix4 pMatrix;
    Matrix4 mvMatrix;
    Matrix4 nMatrix;

    Camera _camera;
    CameraInteractor _interactor;
    Picker _picker = null;

    List<Shape> shapes = [];

    double _mouseGeoX = 0.0;
    double _mouseGeoY = 0.0;
    bool _axesVisible;
    bool _bboxVisible;
    double _ndcMouseX = 0.0; // [-1..+1]
    double _ndcMouseY = 0.0;

    RenderablePointCloudSet _renderSource;

    AxesShape _axesShape;
    BoxShape _bboxShape;

    Renderer(CanvasElement this._canvas, this.gl, RenderablePointCloudSet rpcSet) {
        _hub = Hub.root;

        _canvas.width = _hub.width;
        _canvas.height = _hub.height;

        var attribs = ['aVertexPosition', 'aVertexColor'];
        var uniforms = ['uMVMatrix', 'uPMatrix', 'uPickingColor', 'uOffscreen'];
        _glProgram = new GlProgram(gl, fragmentShader, vertexShader, attribs, uniforms);
        gl.useProgram(_glProgram._program);

        gl.clearColor(0.0, 0.0, 0.0, 1.0);

        mvMatrix = new Matrix4.identity();

        _camera = new Camera(CameraType.Orbiting);
        _camera.goHome(new Vector3(0.0, 0.0, 50.0));
        _camera.setFocus(new Vector3(0.0, 0.0, 0.0));
        //  camera.setElevation(-22);
        // camera.setAzimuth(37);

        _picker = new Picker(gl, _canvas);

        _interactor = new CameraInteractor(_camera, _canvas, _picker);

        makeObjects();

        _picker.shapes = shapes;

        _axesVisible = false;
        _bboxVisible = false;

        _renderSource = rpcSet;

        //_hub.eventRegistry.MouseMove.subscribe(_handleMouseMove);
        _hub.eventRegistry.DisplayAxes.subscribe(_handleDisplayAxes);
        _hub.eventRegistry.DisplayBbox.subscribe(_handleDisplayBbox);
        //_hub.eventRegistry.UpdateCameraEyePosition.subscribe(_handleUpdateCameraEyePosition);
        //_hub.eventRegistry.UpdateCameraTargetPosition.subscribe(_handleUpdateCameraTargetPosition);

        _hub.eventRegistry.WindowResize.subscribe0(_handleWindowResize);
    }

    void makeObjects() {
        var axes = new AxesShape(gl);
        axes.modelMatrix.scale(10.0, 10.0, 10.0);
        shapes.add(axes);
        _axesShape = axes;

        var axes2 = new AxesShape(gl);
        axes2.modelMatrix.scale(2.5, 2.5, 2.5);
        axes2.modelMatrix.rotate(new Vector3(-1.0, -1.0, -1.0), 90.0);
        axes2.modelMatrix.translate(-0.5, -0.5, -0.5);
        shapes.add(axes2);

        var line = new LineShape(gl);
        shapes.add(line);

        var box = new BoxShape(gl);
        box.modelMatrix.translate(-9.0, -9.0, -9.0);
        shapes.add(box);
        _bboxShape = box;

        var blob = new CloudShape(gl);
        shapes.add(blob);
    }

    void update() {
        // ???
    }

    void draw(num viewWidth, num viewHeight, num aspect) {

        Shape.offscreen = 1;
        //off-screen rendering
        gl.bindFramebuffer(FRAMEBUFFER, _picker._frameBNuffer);
        _drawScene(viewWidth, viewHeight, aspect);

        Shape.offscreen = 0;
        //on-screen rendering
        gl.bindFramebuffer(FRAMEBUFFER, null);
        _drawScene(viewWidth, viewHeight, aspect);
    }

    void _drawScene(num viewWidth, num viewHeight, num aspect) {
        gl.viewport(0, 0, viewWidth, viewHeight);
        gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
        gl.enable(DEPTH_TEST);
        gl.disable(BLEND);

        pMatrix = makePerspectiveMatrix(degToRad(_camera.fovy), aspect, 0.1, 100.0);

        for (var renderable in shapes) {
            var vMatrix = _camera.getViewTransform();
            var mMatrix = renderable.modelMatrix;
            mvMatrix = vMatrix * mMatrix;
            renderable.draw(
                    _glProgram._attributes['aVertexPosition'],
                    _glProgram._attributes['aVertexColor'],
                    _setMatrixUniforms);
        }
    }

    void _setMatrixUniforms(Shape r) {
        gl.uniformMatrix4fv(_glProgram._uniforms['uPMatrix'], false, pMatrix.storage);
        gl.uniformMatrix4fv(_glProgram._uniforms['uMVMatrix'], false, mvMatrix.storage);
        gl.uniform1i(_glProgram._uniforms['uOffscreen'], Shape.offscreen);
    }

    void tick(time) {
        window.animationFrame.then(tick);
        draw(_canvas.width, _canvas.height, _canvas.width / _canvas.height);
    }

    void _handleWindowResize() {
        final w = _hub.width;
        final h = _hub.height;
        _canvas.width = w;
        _canvas.height = h;
    }

    void _handleDisplayAxes(bool v) {
        _axesVisible = v;
        _axesShape.visible = v;
    }

    void _handleDisplayBbox(bool v) {
        _bboxVisible = v;
        _bboxShape.visible = v;
    }

}


/***
    Vector3 _cameraHomeEyePoint;
    Vector3 _cameraHomeTargetPoint;
    Vector3 _cameraUpVector;
    Vector3 _cameraCurrentEyePoint;
    Vector3 _cameraCurrentTargetPoint;

    void _handleUpdateCameraTargetPosition(Vector3 data) {
        if (data == null) data = _cameraHomeTargetPoint;
        data.copyInto(_cameraCurrentTargetPoint);
        _updateCameraModel();
    }

    void _handleUpdateCameraEyePosition(Vector3 data) {
        if (data == null) data = _cameraHomeEyePoint;
        data.copyInto(_cameraCurrentEyePoint);
        _updateCameraModel();
    }

    void _updateCameraModel() {
        _camera.position.setFrom(_cameraCurrentEyePoint);
        _camera.up.setFrom(_cameraUpVector);
        _camera.lookAt(_cameraCurrentTargetPoint);
    }


    void update() {
        // model space ...(xmin,ymin,zmin)..(xmax,ymax,zmax)...
        // world space ...(0,0)..(xlen,ylen)...
        //
        // min point of the model becomes the origin of world space

        var theMin = _renderSource.min;
        var theLen = _renderSource.len;
        if (_renderSource.length == 0) {
            theMin = new Vector3.zero();
            theLen = new Vector3(100.0, 100.0, 100.0);
        }

        modelToWorld = new Matrix4.identity();
        modelToWorld.translate(-theMin);

        {
            for (var rpc in _renderSource.renderablePointClouds) {
                var obj = rpc.buildParticleSystem();
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
            if (_bboxVisible) {
                _scene.add(_bboxObject);
            }
        }

        {
            // axes model space is (0,0,0)..(100,100,100)
            _axesObject = new AxesObject();
            Vector3 a = new Vector3(100.0, 100.0, 100.0);
            Vector3 b = theLen.clone();
            Vector3 c = b.divide(a).scale(1.0 / 4.0);
            var axesModelToWorld = new Matrix4.identity().scale(c);
            _axesObject.applyMatrix(axesModelToWorld);
            //if (_axesVisible) {
            _scene.add(_axesObject);
            //}
        }


        {
            // camera positions are computed in geo space, but maintained in world space
            _cameraHomeEyePoint = RenderUtils.getCameraPointEye(_renderSource);
            _cameraHomeTargetPoint = RenderUtils.getCameraPointTarget(_renderSource);

            // move position to world space
            _cameraHomeEyePoint.applyProjection(modelToWorld);
            _cameraHomeTargetPoint.applyProjection(modelToWorld);
            _cameraUpVector = new Vector3(0.0, 0.0, 1.0);

            _cameraCurrentEyePoint = _cameraHomeEyePoint;
            _cameraCurrentTargetPoint = _cameraHomeTargetPoint;

            _addCamera();
            _addCameraControls();
            _cameraControls.target = _cameraHomeTargetPoint;

            _updateCameraModel();
        }

    }


    Vector3 fromMouseToNdc(int newX, int newY) {

        // event.client.x,y is from upper left (0,0) of entire browser window

        // x,y is from upper left (0,0) of the canvas
        var x = newX - _canvasOffsetX;
        var y = newY - _canvasOffsetY;

        //print("screen: $x $y");

        // ncdX,Y is from lower left (-1,-1) to upper right (+1,+1) of the canvas
        final double ndcX = (x / _canvasWidth) * 2 - 1;
        final double ndcY = -(y / _canvasHeight) * 2 + 1;

        assert(ndcX > -1.01 && ndcX < 1.01);
        assert(ndcY > -1.01 && ndcY < 1.01);

        var vec = new Vector3(ndcX, ndcY, 0.0);
        return vec;
    }

    Vector3 fromNdcToModel(double ndcX, double ndcY) {
        var vector = new Vector3(ndcX, ndcY, 0.5);

        Ray ray = _projector.pickingRay(vector.clone(), _camera);

        var q = VectorAtZ(ray.origin, ray.direction, 0.0);

        Matrix4 inv = modelToWorld.clone();
        inv.copyInverse(inv);

        var qq = q.clone();
        qq.applyProjection(inv);

        return qq;
    }



    void _handleMouseMove(MouseMoveData data) {
        if (this.canvas != data.canvas) return;

        var ndcVec = fromMouseToNdc(data.newX, data.newY);

        _ndcMouseX = ndcVec.x;
        _ndcMouseY = ndcVec.y;

        //print("ncd: $_ndcMouseX $_ndcMouseY");
    }

    Vector3 VectorAtZ(Vector3 origin, Vector3 direction, double z) {
        var o = origin.clone();
        var d = direction.clone();

        /*if (d.z < 0.001 && d.z > -0.001) {
            if (d.z < 0.0) {
                d.z = -0.001;
            } else {
                d.z = 0.001;
            }
        }*/

        var t = z - o.z;
        /*if (t < 0.001 && t > -0.001) {
            if (t < 0.0) {
                t = -0.001;
            } else {
                t = 0.001;
            }
        }*/

        var k = t / d.z;

        var vec = o + d * k;

        return vec;
    }


    void _updateMouseWorldCoords() {
        {
            final Vector3 vModel = fromNdcToModel(_ndcMouseX, _ndcMouseY);
            _mouseGeoX = vModel.x;
            _mouseGeoY = vModel.y;

            _hub.eventRegistry.MouseGeoCoords.fire(new Vector3(_mouseGeoX, _mouseGeoY, this._renderSource.min.z));
        }
    }
}
***/
