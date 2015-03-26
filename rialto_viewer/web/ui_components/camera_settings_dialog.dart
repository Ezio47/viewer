// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class CameraSettingsDialog extends DialogVM {

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

    CameraSettingsDialog(String id) : super(id) {

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

        _register(_eyeLon);
        _register(_eyeLat);
        _register(_eyeHeight);
        _register(_targetLon);
        _register(_targetLat);
        _register(_targetHeight);
        _register(_fov);
        _register(_upX);
        _register(_upY);
        _register(_upZ);
    }

    @override
    void _show() {}

    @override
    void _hide() {
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
            Rialto.error("Invalid camera settings (eye position)");
            return;
        }

        final targetOkay = (targetLon != null && targetLat != null && targetHeight != null);
        if (!targetOkay) {
            Rialto.error("Invalid camera settings (target position)");
            return;
        }

        bool upOkay = (upX != null && upY != null && upZ != null);
        if (!upOkay) {
            Rialto.error("Invalid camera settings (up direction)");
            return;
        }
        final fovOkay = (fov != null);
        if (!fovOkay) {
            Rialto.error("Invalid camera settings (fov value)");
            return;
        }

        Cartographic3 eye = new Cartographic3(eyeLon, eyeLat, eyeHeight);
        Cartographic3 target = new Cartographic3(targetLon, targetLat, targetHeight);
        Cartesian3 up = new Cartesian3(upX, upY, upZ);

        _hub.commands.zoomTo(eye, target, up, fov);
    }
}
