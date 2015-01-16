// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class Camera {
    Hub _hub;

    // these two are relative to the loaded data, not the globe
    Cartographic3 _defaultCameraEyePosition = new Cartographic3(0.0, 0.0, 15000.0);
    Cartographic3 _defaultTargetPosition = new Cartographic3(0.0, 0.0, 0.0);

    final Cartesian3 _defaultUpDirection = new Cartesian3(0.0, 0.0, 1.0);
    final double _defaultFov = 60.0;

    Cartographic3 _eyePosition;
    Cartographic3 _targetPosition;
    Cartesian3 _upDirection;
    double _cameraFov;

    Camera() {
        _hub = Hub.root;
        _hub.eventRegistry.UpdateCamera.subscribe(_handleUpdateCamera);
    }

    void changeDataExtents(double west, double south, double east, double north) {
        double centerLon = east + (west - east) / 2.0;
        double centerLat = south + (north - south) / 2.0;

        _defaultTargetPosition = new Cartographic3(centerLon, centerLat, 0.0);

        var h = max(west - east, north - south) * 1000.0;
        _defaultCameraEyePosition = new Cartographic3(centerLon, centerLat, h);
    }

    void _handleUpdateCamera(CameraData data) {
        assert(data != null);

        switch (data.mode) {
            case 0:
                _eyePosition = data.eye;
                _targetPosition = data.target;
                _upDirection = data.up;
                _cameraFov = data.fov;
                break;
            case 1: // world view
                _hub.cesium.goHome();
                return;
            case 2: // data view
                _eyePosition = _defaultCameraEyePosition;
                _targetPosition = _defaultTargetPosition;
                _upDirection = _defaultUpDirection;
                _cameraFov = _defaultFov;
                break;
            default:
                assert(false);
                break;
        }

        _hub.cesium.lookAt(_eyePosition, _targetPosition, _upDirection, _cameraFov);
    }
}
