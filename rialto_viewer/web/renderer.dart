// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class Renderer {
    Hub _hub;

    Matrix4 pMatrix;
    Matrix4 mvMatrix;

    double _mouseGeoX = 0.0;
    double _mouseGeoY = 0.0;
    bool _axesVisible;
    bool _bboxVisible;
    double _ndcMouseX = 0.0; // [-1..+1]
    double _ndcMouseY = 0.0;

    RenderablePointCloudSet _renderSource;

    AxesShape _axesShape;
    BboxShape _bboxShape;

    List<Annotation> annotations = new List<Annotation>();
    List<Measurement> measurements = new List<Measurement>();

    Vector3 _cloudMin;
    Vector3 _cloudMax;
    Vector3 _cloudLen;

    Vector3 _defaultCameraEyePosition;
    Vector3 _cameraEyePosition;
    Vector3 _defaultCameraTargetPosition;
    Vector3 _cameraTargetPosition;
    Vector3 _defaultCameraUpDirection;
    Vector3 _cameraUpDirection;
    // BUG: camera fov?

    Renderer(RenderablePointCloudSet rpcSet) {
        _hub = Hub.root;

        _renderSource = rpcSet;


        _axesVisible = false;
        _bboxVisible = false;

        //_hub.eventRegistry.MouseMove.subscribe(_handleMouseMove);
        _hub.eventRegistry.DisplayAxes.subscribe(_handleDisplayAxes);
        _hub.eventRegistry.DisplayBbox.subscribe(_handleDisplayBbox);
        //_hub.eventRegistry.UpdateCameraEyePosition.subscribe(_handleUpdateCameraEyePosition);
        //_hub.eventRegistry.UpdateCameraTargetPosition.subscribe(_handleUpdateCameraTargetPosition);
    }

    Vector3 get defaultCameraEyePosition {
        return _defaultCameraEyePosition;
    }

    set defaultCameraEyePosition(Vector3 value) {
        _defaultCameraEyePosition = value;
    }

    Vector3 get cameraEyePosition {
        return _cameraEyePosition;
    }

    set cameraEyePosition(Vector3 value) {
        _cameraEyePosition = value;
    }

    Vector3 get defaultCameraTargetPosition {
        return _defaultCameraTargetPosition;
    }

    set defaultCameraTargetPosition(Vector3 value) {
        _defaultCameraTargetPosition = value;
    }

    Vector3 get cameraTargetPosition {
        return _cameraTargetPosition;
    }

    set cameraTargetPosition(Vector3 value) {
        _cameraTargetPosition = value;
    }

    Vector3 get defaultCameraUpDirection {
        return _defaultCameraUpDirection;
    }

    set defaultCameraUpDirection(Vector3 value) {
        _defaultCameraUpDirection = value;
    }

    Vector3 get cameraUpDirection {
        return _cameraUpDirection;
    }

    set cameraUpDirection(Vector3 value) {
        _cameraUpDirection = value;
    }

    void goHome() {
        cameraEyePosition = defaultCameraEyePosition;
        cameraTargetPosition = defaultCameraTargetPosition;
        cameraUpDirection = new Vector3(0.0, 0.0, 1.0);
    }

    void checkUpdate([dynamic theScene=null, dynamic theTime=null]) {
    }

    void update([dynamic theScene=null, dynamic theTime=null]) {
        // model space: cloud's (xmin,ymin,zmin)..cloud's (xmax,ymax,zmax)
        // world space: (0,0,0).. cloud's (xlen,ylen,zlen)
        //
        // note mid-point of the cloud model gets tranlated to the origin of world space

        _hub.shapesList.forEach((s) => s.remove());
        _hub.shapesList.clear();

        _cloudMin = _renderSource.min;
        _cloudMax = _renderSource.max;
        _cloudLen = _renderSource.len;

        if (_renderSource.length == 0) {
            // a reasonable default
            _cloudMin = new Vector3.zero();
            _cloudLen = new Vector3(1.0, 1.0, 1.0);
        }

        final cloudLen12 = _cloudLen / 2.0;
        final cloudLen14 = _cloudLen / 4.0;

        final ideal = new Vector3(-1.0, -2.0, 2.0);
        defaultCameraEyePosition = new Vector3(ideal.x * _cloudLen.x, ideal.y * _cloudLen.y, ideal.z * _cloudLen.z);
        defaultCameraTargetPosition = new Vector3(0.0, 0.0, 0.0);
        defaultCameraUpDirection = new Vector3(0.0, 0.0, 1.0);
        cameraEyePosition = defaultCameraEyePosition;
        cameraTargetPosition = defaultCameraTargetPosition;
        cameraUpDirection = defaultCameraUpDirection;

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
            // axes model space is (0 .. 0.25 * cloudLen)
       //     _axesShape = new AxesShape(_cloudMin, cloudLen14);
       //     _hub.shapesList.add(_axesShape);
        }

        {
            // bbox model space is (cloudMin....cloudMax)
            _bboxShape = new BboxShape(_cloudMin, _cloudMax);
            _hub.shapesList.add(_bboxShape);
        }

        {
            for (var rpc in _renderSource.renderablePointClouds) {
                var obj = rpc.buildParticleSystem();
                obj.isVisible = rpc.visible;
                _hub.shapesList.add(obj);
            }
        }

        for (var annotation in annotations) {
            addAnnotationToScene(annotation);
        }

        for (var measurement in measurements) {
            addMeasurementToScene(measurement);
        }

        goHome();
    }

    void addAnnotationToScene(Annotation annotation) {
        _hub.shapesList.add(annotation.shape);
    }

    void addMeasurementToScene(Measurement measurement) {
        _hub.shapesList.add(measurement.shape);
    }

    void draw(num viewWidth, num viewHeight, num aspect) {
    }


    void _handleDisplayAxes(bool v) {
        if (_axesShape == null) return;
        _axesVisible = v;
        _axesShape.isVisible = v;
    }

    void _handleDisplayBbox(bool v) {
        if (_bboxShape == null) return;
        _bboxVisible = v;
        _bboxShape.isVisible = v;
    }

    void _handleUpdateCameraTargetPosition(Vector3 data) {
        cameraTargetPosition = data;
    }

    void _handleUpdateCameraEyePosition(Vector3 data) {
        cameraEyePosition = data;
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
