// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class Camera {
    Hub _hub;

    Vector3 defaultDataCameraEyePosition;
    Vector3 defaultDataCameraTargetPosition;

    Vector3 defaultCameraUpDirection;
    double defaultCameraFov;

    Vector3 _cameraEyePosition;
    Vector3 _cameraTargetPosition;
    Vector3 _cameraUpDirection;
    double _cameraFov;

    Camera() {
        _hub = Hub.root;

        defaultDataCameraEyePosition = new Vector3(0.0, 0.0, 15000.0);
        defaultDataCameraTargetPosition = new Vector3(0.0, 0.0, 0.0);

        defaultCameraUpDirection = new Vector3(0.0, 0.0, 1.0);

        defaultCameraFov = 60.0;

        _hub.eventRegistry.UpdateCamera.subscribe(_handleUpdateCamera);
    }

    void changeDataExtents(double west, double south, double east, double north) {
        double centerLon = east + (west - east) / 2.0;
        double centerLat = south + (north - south) / 2.0;

        defaultDataCameraTargetPosition = new Vector3(centerLon, centerLat, 0.0);

        var h = max(west - east, north - south) * 1000.0;
        defaultDataCameraEyePosition = new Vector3(centerLon, centerLat, h);
    }

    void _handleUpdateCamera(CameraData data) {
        assert(data != null);

        switch (data.mode) {
            case 0:
                cameraEyePosition = data.eye;
                cameraTargetPosition = data.target;
                cameraUpDirection = data.up;
                cameraFov = data.fov;
                break;
            case 1: // world view
                _hub.cesium.goHome();
                return;
            case 2: // data view
                cameraEyePosition = defaultDataCameraEyePosition;
                cameraTargetPosition = defaultDataCameraTargetPosition;
                cameraUpDirection = defaultCameraUpDirection;
                cameraFov = defaultCameraFov;
                break;
            default:
                assert(false);
                break;
        }

        // _hub.cesium.setPositionCartographic(cameraTargetPosition.x, cameraTargetPosition.y, cameraTargetPosition.z);
        // TODO: fov
        _hub.cesium.lookAt(
                cameraEyePosition.x,
                cameraEyePosition.y,
                cameraEyePosition.z,
                cameraTargetPosition.x,
                cameraTargetPosition.y,
                cameraTargetPosition.z,
                cameraUpDirection.x,
                cameraUpDirection.y,
                cameraUpDirection.z,
                cameraFov);
    }

    Vector3 get cameraEyePosition {
        return _cameraEyePosition;
    }

    set cameraEyePosition(Vector3 value) {
        _cameraEyePosition = value;
    }

    Vector3 get cameraTargetPosition {
        return _cameraTargetPosition;
    }

    set cameraTargetPosition(Vector3 value) {
        _cameraTargetPosition = value;
    }

    Vector3 get cameraUpDirection {
        return _cameraUpDirection;
    }

    set cameraUpDirection(Vector3 value) {
        _cameraUpDirection = value;
    }

    double get cameraFov {
        return _cameraFov;
    }

    set cameraFov(double value) {
        _cameraFov = value;
    }
}
