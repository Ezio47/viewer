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

        _hub.camera.eye = new Vector3(0.0, 0.0, 200.0);
        //  camera.setElevation(-22);
        // camera.setAzimuth(37);

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

        _hub.camera.defaultEye = new Vector3(0.0, 0.0, 1800.0);
        _hub.camera.defaultTarget = new Vector3(0.0, 0.0, 0.0);
        _hub.camera.eye = _hub.camera.defaultEye;
        _hub.camera.target = _hub.camera.defaultTarget;
        _hub.camera.azimuth = 0.0;
        _hub.camera.elevation = 0.0;
        _hub.camera.fovy = 65.0;

        // "rotate then translate" (spinning) vs "translate then rotate" (orbiting)
        //
        // s = new Matrix4.diagonal3Values(1.0, 2.0, 1.0);
        // t = new Matrix4.translationValues(0.0, 3.0, 0.0);
        // rx = new Matrix4.rotationX(degToRad(0.0));
        // ry = new Matrix4.rotationY(degToRad(0.0));
        // rz = new Matrix4.rotationZ(degToRad(20.0));
        // r = (rx * ry * rz);
        // modelMatrix = t * r * s;

        {
            // axes model space is (0,0,0)..(0.25 * theLen)
            _axesShape = new AxesShape(gl);
            Matrix4 s = GlMath.makeScale(theLen.x / 4.0, theLen.y / 4.0, theLen.z / 4.0);
            Matrix4 t = GlMath.makeTranslation(0.0, 0.0, 0.0);
            Matrix4 rx = GlMath.makeXRotation(degToRad(0.0));
            Matrix4 ry = GlMath.makeYRotation(degToRad(0.0));
            Matrix4 rz = GlMath.makeZRotation(degToRad(0.0));
            var m = s * rz;
            m = m * ry;
            m = m * rx;
            m = m * t;
            _axesShape.modelMatrix = m;
            _hub.shapesList.add(_axesShape);
        }

        {
            // bbox model space is (-len/2)..(+len/2)
            _bboxShape = new BoxShape(gl);
            Matrix4 s = GlMath.makeScale(theLen.x, theLen.y, theLen.z);
            var p = theLen / 2.0;
            Matrix4 t = GlMath.makeTranslation(-p.x / theLen.x, -p.y / theLen.y, -p.z / theLen.z);
            Matrix4 rx = GlMath.makeXRotation(degToRad(0.0));
            Matrix4 ry = GlMath.makeYRotation(degToRad(0.0));
            Matrix4 rz = GlMath.makeZRotation(degToRad(0.0));
            var m = s * rz;
            m = m * ry;
            m = m * rx;
            m = m * t;
            _bboxShape.modelMatrix = m;
            _hub.shapesList.add(_bboxShape);
        }

        {
            for (var rpc in _renderSource.renderablePointClouds) {
                var obj = rpc.buildParticleSystem();
                obj.isVisible = rpc.visible;
                Matrix4 s = GlMath.makeScale(1.0, 1.0, 1.0);
                var p = theLen / 2.0;
                Matrix4 t = GlMath.makeTranslation(-theMin.x - p.x, -theMin.y - p.x, -theMin.z - p.z);
                Matrix4 rx = GlMath.makeXRotation(degToRad(0.0));
                Matrix4 ry = GlMath.makeYRotation(degToRad(0.0));
                Matrix4 rz = GlMath.makeZRotation(degToRad(0.0));
                var m = s * rz;
                m = m * ry;
                m = m * rx;
                m = m * t;
                obj.modelMatrix = m;
                _hub.shapesList.add(obj);
            }
        }

        for (var annotation in annotations) {
            AnnotationShape shape = annotation.shape;
            Matrix4 s = GlMath.makeScale(1.0, 1.0, 1.0);
            Matrix4 t = GlMath.makeTranslation(-theLen.x, -theLen.y, -theLen.z);
            Matrix4 rx = GlMath.makeXRotation(degToRad(0.0));
            Matrix4 ry = GlMath.makeYRotation(degToRad(0.0));
            Matrix4 rz = GlMath.makeZRotation(degToRad(0.0));
            var m = s * rz;
            m = m * ry;
            m = m * rx;
            m = m * t;
            shape.modelMatrix = m;
            _hub.shapesList.add(shape);
        }

        _hub.camera.goHome();
    }

    void draw(num viewWidth, num viewHeight, num aspect) {

        //off-screen rendering
        if (_hub.isPickingEnabled) {
            gl.bindFramebuffer(FRAMEBUFFER, _hub.picker._frameBuffer);
            _drawScene(viewWidth, viewHeight, aspect, offscreen: true);
        }

        //on-screen rendering
        gl.bindFramebuffer(FRAMEBUFFER, null);
        _drawScene(viewWidth, viewHeight, aspect, offscreen: false);
    }

    void _drawScene(num viewWidth, num viewHeight, num aspect, {bool offscreen}) {

        gl.viewport(0, 0, viewWidth, viewHeight);
        gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
        gl.enable(DEPTH_TEST);
        gl.disable(BLEND);

        pMatrix = GlMath.makePerspective(degToRad(60.0), aspect, 1.0, 2000.0);
        var viewMatrix = _hub.camera.getViewMatrix();

        for (var shape in _hub.shapesList) {
            var modelMatrix = shape.modelMatrix;
            mvMatrix = viewMatrix * modelMatrix;
            shape.draw(
                    _glProgram._attributes['aVertexPosition'],
                    _glProgram._attributes['aVertexColor'],
                    _setMatrixUniforms,
                    offscreen);
        }
    }

    void _setMatrixUniforms(Shape shape, bool offscreen) {
        gl.uniformMatrix4fv(_glProgram._uniforms['uPMatrix'], false, pMatrix.storage);
        gl.uniformMatrix4fv(_glProgram._uniforms['uMVMatrix'], false, mvMatrix.storage);
        gl.uniform1i(_glProgram._uniforms['uOffscreen'], offscreen ? 1 : 0);
    }

    void tick(time) {
        //window.animationFrame.then(tick);
        //draw(_canvas.width, _canvas.height, _canvas.width / _canvas.height);

        // BUG???

        window.animationFrame.then((_) {
            draw(_canvas.width, _canvas.height, _canvas.width / _canvas.height);
            tick(0);
        });
    }

    void _handleWindowResize() {
        final w = _hub.width;
        final h = _hub.height;
        _canvas.width = w;
        _canvas.height = h;
    }

    void _handleDisplayAxes(bool v) {
        _axesVisible = v;
        _axesShape.isVisible = v;
    }

    void _handleDisplayBbox(bool v) {
        _bboxVisible = v;
        _bboxShape.isVisible = v;
    }

    void _handleUpdateCameraTargetPosition(Vector3 data) {
        _hub.camera.target = _hub.camera.defaultTarget;
    }

    void _handleUpdateCameraEyePosition(Vector3 data) {
        _hub.camera.eye = _hub.camera.defaultEye;
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

        Ray ray = _projector.pickingRay(vector.clone(), camera);

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
