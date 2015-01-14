// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class Camera {
    Hub _hub;

    Vector3 defaultCameraEyePosition;
    Vector3 defaultCameraTargetPosition;
    Vector3 defaultCameraUpDirection;
    double defaultCameraFov;

    Vector3 _cameraEyePosition;
    Vector3 _cameraTargetPosition;
    Vector3 _cameraUpDirection;
    double _cameraFov;

    Camera() {
        _hub = Hub.root;

        defaultCameraEyePosition = new Vector3(0.0, 0.0, 15000.0);
        defaultCameraTargetPosition = new Vector3(0.0, 0.0, 0.0);
        defaultCameraUpDirection = new Vector3(0.0, 0.0, 1.0);
        defaultCameraFov = 60.0;

        _hub.eventRegistry.UpdateCamera.subscribe(_handleUpdateCamera);
    }


    void _handleUpdateCamera(CameraData data) {
        if (data == null) {
            cameraEyePosition = defaultCameraEyePosition;
            cameraEyePosition = defaultCameraEyePosition;
            cameraUpDirection = defaultCameraUpDirection;
            cameraFov = defaultCameraFov;
        } else {
            cameraEyePosition = data.eye;
            cameraTargetPosition = data.target;
            cameraUpDirection = data.up;
            cameraFov = data.fov;
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
