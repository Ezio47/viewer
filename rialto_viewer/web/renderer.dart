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
    CameraControl _interactor;
    Picker _picker = null;

    double _mouseGeoX = 0.0;
    double _mouseGeoY = 0.0;
    bool _axesVisible;
    bool _bboxVisible;
    double _ndcMouseX = 0.0; // [-1..+1]
    double _ndcMouseY = 0.0;

    RenderablePointCloudSet _renderSource;

    AxesShape _axesShape;
    BoxShape _bboxShape;

    List<Annotation> annotations = new List<Annotation>();

    Renderer(CanvasElement this._canvas, this.gl, RenderablePointCloudSet rpcSet) {
        _hub = Hub.root;

        _canvas.width = _hub.width;
        _canvas.height = _hub.height;

        _renderSource = rpcSet;

        var attribs = ['aVertexPosition', 'aVertexColor'];
        var uniforms = ['uMVMatrix', 'uPMatrix', 'uPickingColor', 'uOffscreen'];
        _glProgram = new GlProgram(gl, fragmentShader, vertexShader, attribs, uniforms);
        gl.useProgram(_glProgram._program);

        gl.clearColor(0.0, 0.0, 0.0, 1.0);

        mvMatrix = new Matrix4.identity();

        _camera = new Camera(Camera.ORBITING);
        _camera.eye = new Vector3(0.0, 0.0, 50.0);
        //  camera.setElevation(-22);
        // camera.setAzimuth(37);

        _picker = new Picker(gl, _canvas);

        _interactor = new CameraControl(_camera, _canvas, _picker);

        update();

        _axesVisible = false;
        _bboxVisible = false;

        //_hub.eventRegistry.MouseMove.subscribe(_handleMouseMove);
        _hub.eventRegistry.DisplayAxes.subscribe(_handleDisplayAxes);
        _hub.eventRegistry.DisplayBbox.subscribe(_handleDisplayBbox);
        //_hub.eventRegistry.UpdateCameraEyePosition.subscribe(_handleUpdateCameraEyePosition);
        //_hub.eventRegistry.UpdateCameraTargetPosition.subscribe(_handleUpdateCameraTargetPosition);

        _hub.eventRegistry.WindowResize.subscribe0(_handleWindowResize);
    }

    // this gets called whenever something major changes, e.g. add a new cloud
    void update() {
        // model space: cloud's (xmin,ymin,zmin)..cloud's (xmax,ymax,zmax)
        // world space: (0,0,0).. cloud's (xlen,ylen,zlen)
        //
        // note mid-point of the cloud model gets tranlated to the origin of world space

        _hub.shapesList.clear();

        var theMin = _renderSource.min;
        var theLen = _renderSource.len;

        if (_renderSource.length == 0) {
            // a reasonable default
            theMin = new Vector3.zero();
            theLen = new Vector3(1.0, 1.0, 1.0);
        }

        _camera.eye = new Vector3(0.0, 0.0, 3000.0);
        _camera.defaultEye = new Vector3(0.0, 0.0, 3000.0);
        _camera.target = new Vector3(0.0, 0.0, 0.0);
        _camera.defaultTarget = new Vector3(0.0, 0.0, 0.0);

        {
            // axes model space is (0,0,0)..(0.25 * theLen)
            _axesShape = new AxesShape(gl);
            _axesShape.modelMatrix.scale(theLen * 0.25);
            _hub.shapesList.add(_axesShape);
        }


        {
            // bbox model space is (0,0,0)..(theLen)
            _bboxShape = new BoxShape(gl);
            _bboxShape.modelMatrix.translate(-theLen / 2.0);
            _bboxShape.modelMatrix.scale(theLen);
            _hub.shapesList.add(_bboxShape);
        }

        {
            for (var rpc in _renderSource.renderablePointClouds) {
                var obj = rpc.buildParticleSystem();
                obj.visible = rpc.visible;
                obj.modelMatrix.translate(-theMin - theLen / 2.0);
                _hub.shapesList.add(obj);
            }
        }

        for (var annotation in annotations) {
            AnnotationShape shape = annotation.shape;
            shape.modelMatrix.translate(-theMin - theLen / 2.0);
            _hub.shapesList.add(shape);
        }

        _camera.goHome();
    }

    void draw(num viewWidth, num viewHeight, num aspect) {

        //off-screen rendering
        if (_hub.isPickingEnabled) {
            Hub.root.offscreenMode = 1;
            gl.bindFramebuffer(FRAMEBUFFER, _picker._frameBNuffer);
            _drawScene(viewWidth, viewHeight, aspect);
        }

        //on-screen rendering
        Hub.root.offscreenMode = 0;
        gl.bindFramebuffer(FRAMEBUFFER, null);
        _drawScene(viewWidth, viewHeight, aspect);
    }

    void _drawScene(num viewWidth, num viewHeight, num aspect) {
        _camera.update();

        gl.viewport(0, 0, viewWidth, viewHeight);
        gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
        gl.enable(DEPTH_TEST);
        gl.disable(BLEND);

        pMatrix = _camera.getPerspectiveMatrix(aspect);

        var vMatrix = _camera.getViewMatrix();
        for (var shape in _hub.shapesList) {
            var mMatrix = shape.modelMatrix;
            mvMatrix = vMatrix * mMatrix;
            shape.draw(
                    _glProgram._attributes['aVertexPosition'],
                    _glProgram._attributes['aVertexColor'],
                    _setMatrixUniforms);
        }
    }

    void _setMatrixUniforms(Shape r) {
        gl.uniformMatrix4fv(_glProgram._uniforms['uPMatrix'], false, pMatrix.storage);
        gl.uniformMatrix4fv(_glProgram._uniforms['uMVMatrix'], false, mvMatrix.storage);
        gl.uniform1i(_glProgram._uniforms['uOffscreen'], Hub.root.offscreenMode);
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

    void _handleUpdateCameraTargetPosition(Vector3 data) {
        _camera.target = _camera.defaultTarget;
    }

    void _handleUpdateCameraEyePosition(Vector3 data) {
        _camera.eye = _camera.defaultEye;
    }
}



/***
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
