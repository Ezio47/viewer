// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class Renderer {
    Hub _hub;

    double _mouseGeoX = 0.0;
    double _mouseGeoY = 0.0;
    bool _axesVisible;
    bool _bboxVisible;

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
    double _defaultCameraFov;
    double _cameraFov;

    Renderer(RenderablePointCloudSet rpcSet) {
        _hub = Hub.root;

        _renderSource = rpcSet;

        _axesVisible = false;
        _bboxVisible = false;

        _hub.eventRegistry.DisplayAxes.subscribe(_handleDisplayAxes);
        _hub.eventRegistry.DisplayBbox.subscribe(_handleDisplayBbox);
        _hub.eventRegistry.UpdateCamera.subscribe(_handleUpdateCamera);
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

    double get defaultCameraFov {
        return _defaultCameraFov;
    }

    set defaultCameraFov(double value) {
        _defaultCameraFov = value;
    }

    double get cameraFov {
        return _cameraFov;
    }

    set cameraFov(double value) {
        _cameraFov= value;
    }

    void _handleUpdateCamera(CameraData data) {
        cameraEyePosition = data.eye;
        cameraTargetPosition = data.target;
        cameraUpDirection = data.up;
        cameraFov = data.fov;

        //double westLon = -10.0;
        //double southLat = -10.0;
        //double eastLon = 10.0;
        //double northLat = 10.0;
        ////Vector3 v = _hub.cesium.getRectangleCameraCoordinates(westLon, southLat, eastLon, northLat);
        //_hub.cesium.viewRectangle(westLon, southLat, eastLon, northLat);

        // TODO: use eye, up, fov
        _hub.cesium.setPositionCartographic(cameraTargetPosition.x, cameraTargetPosition.y, cameraTargetPosition.z);
    }

    void checkUpdate([dynamic theScene = null, dynamic theTime = null]) {
    }

    void update([dynamic theScene = null, dynamic theTime = null]) {

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

        /*
        double westLon = -10.0;
        double southLat = -10.0;
        double eastLon = 10.0;
        double northLat = 10.0;
        //Vector3 v = _hub.cesium.getRectangleCameraCoordinates(westLon, southLat, eastLon, northLat);
        _hub.cesium.viewRectangle(westLon, southLat, eastLon, northLat);
        */

        final cloudLen12 = _cloudLen / 2.0;
        final cloudLen14 = _cloudLen / 4.0;

        final ideal = new Vector3(-1.0, -2.0, 2.0);
        defaultCameraEyePosition = new Vector3(ideal.x * _cloudLen.x, ideal.y * _cloudLen.y, ideal.z * _cloudLen.z);
        defaultCameraTargetPosition = new Vector3(0.0, 0.0, 0.0);
        defaultCameraUpDirection = new Vector3(0.0, 0.0, 1.0);
        cameraEyePosition = defaultCameraEyePosition;
        cameraTargetPosition = defaultCameraTargetPosition;
        cameraUpDirection = defaultCameraUpDirection;

        {
            // axes model space is (0 .. 0.25 * cloudLen)
            _axesShape = new AxesShape(_cloudMin, cloudLen14);
            _hub.shapesList.add(_axesShape);
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

      //  _handleMoveCameraHome();
    }

    void addAnnotationToScene(Annotation annotation) {
        _hub.shapesList.add(annotation.shape);
    }

    void addMeasurementToScene(Measurement measurement) {
        _hub.shapesList.add(measurement.shape);
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
