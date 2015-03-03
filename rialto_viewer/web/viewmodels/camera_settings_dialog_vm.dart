// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class CameraSettingsDialogVM extends DialogVM {

    TextInputVM _eyeLon;
    TextInputVM _eyeLat;
    TextInputVM _eyeHeight;
    TextInputVM _targetLon;
    TextInputVM _targetLat;
    TextInputVM _targetHeight;
    TextInputVM _fov;
    TextInputVM _upX;
    TextInputVM _upY;
    TextInputVM _upZ;

    Hub _hub;

    CameraSettingsDialogVM(String id) : super(id) {

        _hub = Hub.root;

        _eyeLon = new TextInputVM("#cameraSettingsDialog_eyeLon", "0.0");
        _eyeLat = new TextInputVM("#cameraSettingsDialog_eyeLat", "0.0");
        _eyeHeight = new TextInputVM("#cameraSettingsDialog_eyeHeight", "15000.0");
        _targetLon = new TextInputVM("#cameraSettingsDialog_targetLon", "0.0");
        _targetLat = new TextInputVM("#cameraSettingsDialog_targetLat", "0.0");
        _targetHeight = new TextInputVM("#cameraSettingsDialog_targetHeight", "0.0");
        _fov = new TextInputVM("#cameraSettingsDialog_fov", "60.0");
        _upX = new TextInputVM("#cameraSettingsDialog_upX", "0.0");
        _upY = new TextInputVM("#cameraSettingsDialog_upY", "0.0");
        _upZ = new TextInputVM("#cameraSettingsDialog_upZ", "1.0");
    }

    @override
    void _show() {
        _eyeLon.clearState();
        _eyeLat.clearState();
        _eyeHeight.clearState();
        _targetLon.clearState();
        _targetLat.clearState();
        _targetHeight.clearState();
        _fov.clearState();
        _upX.clearState();
        _upY.clearState();
        _upZ.clearState();
    }

    @override
    void _hide(bool okay) {
        if (!okay) return;

        _performCameraWork();
    }

    void _performCameraWork() {
        bool eyeChanged = (_eyeLon.changed || _eyeLat.changed || _eyeHeight.changed);
        bool targetChanged = (_targetLon.changed || _targetLat.changed || _targetHeight.changed);
        bool upChanged = (_upX.changed || _upY.changed || _upZ.changed);
        bool fovChanged = (_fov.changed);

        if (!eyeChanged && !targetChanged && !upChanged && !fovChanged) {
            return;
        }

        var eyeLon = _eyeLon.valueAsDouble;
        var eyeLat = _eyeLat.valueAsDouble;
        var eyeHeight = _eyeHeight.valueAsDouble;

        var targetLon = _targetLon.valueAsDouble;
        var targetLat = _targetLat.valueAsDouble;
        var targetHeight = _targetHeight.valueAsDouble;

        var upX = _upX.valueAsDouble;
        var upY = _upY.valueAsDouble;
        var upZ = _upZ.valueAsDouble;

        var fov = _fov.valueAsDouble;

        final eyeOkay = (eyeLon != null && eyeLat != null && eyeHeight != null);
        if (!eyeOkay) {
            Hub.error("Invalid camera settings (eye position)");
            return;
        }

        final targetOkay = (targetLon != null && targetLat != null && targetHeight != null);
        if (!targetOkay) {
            Hub.error("Invalid camera settings (target position)");
            return;
        }

        bool upOkay = (upX != null && upY != null && upZ != null);
        if (!upOkay) {
            Hub.error("Invalid camera settings (up direction)");
            return;
        }
        final fovOkay = (fov != null);
        if (!fovOkay) {
            Hub.error("Invalid camera settings (fov value)");
            return;
        }

        Cartographic3 eye = new Cartographic3(eyeLon, eyeLat, eyeHeight);
        Cartographic3 target = new Cartographic3(targetLon, targetLat, targetHeight);
        Cartesian3 up = new Cartesian3(upX, upY, upZ);

        var data = new CameraData(eye, target, up, fov);
        _hub.commands.updateCamera(data);
    }
}
