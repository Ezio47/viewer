// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class AdvancedSettingsVM extends DialogVM {
    bool axesChecked;
    bool bboxChecked;

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

    CheckboxVM _axesEnabled;
    CheckboxVM _bboxEnabled;

    Hub _hub;

    AdvancedSettingsVM(DialogElement dialogElement, var dollar) : super(dialogElement, dollar) {

        _hub = Hub.root;
        _hub.eventRegistry.DisplayAxes.subscribe((v) => axesChecked = v);
        _hub.eventRegistry.DisplayBbox.subscribe((v) => bboxChecked = v);
        axesChecked = false;
        bboxChecked = false;

        _eyeLon = new TextInputVM($["advancedSettingsDialog_eyeLon"], "0.0");
        _eyeLat = new TextInputVM($["advancedSettingsDialog_eyeLat"], "0.0");
        _eyeHeight = new TextInputVM($["advancedSettingsDialog_eyeHeight"], "15000.0");
        _targetLon = new TextInputVM($["advancedSettingsDialog_targetLon"], "0.0");
        _targetLat = new TextInputVM($["advancedSettingsDialog_targetLat"], "0.0");
        _targetHeight = new TextInputVM($["advancedSettingsDialog_targetHeight"], "0.0");
        _fov = new TextInputVM($["advancedSettingsDialog_fov"], "60.0");
        _upX = new TextInputVM($["advancedSettingsDialog_upX"], "0.0");
        _upY = new TextInputVM($["advancedSettingsDialog_upY"], "0.0");
        _upZ = new TextInputVM($["advancedSettingsDialog_upZ"], "1.0");

        _axesEnabled = new CheckboxVM($["advancedSettingsDialog_axesEnabled"], true);
        _bboxEnabled = new CheckboxVM($["advancedSettingsDialog_bboxEnabled"], true);
    }

    @override
    void _open() {
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

        _axesEnabled.clearState();
        _bboxEnabled.clearState();
    }

    @override
    void _close(bool okay) {
        if (!okay) return;

        _performCameraWork();

        _performBboxWork();
    }

    void _performCameraWork() {
        bool eyeChanged = (_eyeLon.changed && _eyeLat.changed && _eyeHeight.changed);
        bool targetChanged = (_targetLon.changed && _targetLat.changed && _targetHeight.changed);
        bool upChanged = (_upX.changed && _upY.changed && _upZ.changed);
        bool fovChanged = (_fov.changed);

        if (!eyeChanged && !targetChanged && !upChanged && !fovChanged) {
            return;
        }

        var eyeLon = _eyeLon.getValueAsDouble();
        var eyeLat = _eyeLat.getValueAsDouble();
        var eyeHeight = _eyeHeight.getValueAsDouble();

        var targetLon = _targetLon.getValueAsDouble();
        var targetLat = _targetLat.getValueAsDouble();
        var targetHeight = _targetHeight.getValueAsDouble();

        var upX = _upX.getValueAsDouble();
        var upY = _upY.getValueAsDouble();
        var upZ = _upZ.getValueAsDouble();

        var fov = _fov.getValueAsDouble();

        bool eyeOkay = (eyeLon != null && eyeLat != null && eyeHeight != null);
        bool targetOkay = (targetLon != null && targetLat != null && targetHeight != null);
        bool upOkay = (upX != null && upY != null && upZ != null);
        bool fovOkay = (fov != null);

        if (eyeOkay && targetOkay && upOkay && fovOkay) {
            Vector3 eye = new Vector3(eyeLon, eyeLat, eyeHeight);
            Vector3 target = new Vector3(targetLon, targetLat, targetHeight);
            Vector3 up = new Vector3(upX, upY, upZ);

            var data = new CameraData(eye, target, up, fov);
            _hub.eventRegistry.UpdateCamera.fire(data);
        } else {
            assert(false);
            // TODO: print error
        }
    }

    void _performBboxWork() {
        if (_axesEnabled.changed) {
            _hub.eventRegistry.DisplayAxes.fire(_axesEnabled.value);
        }
        if (_bboxEnabled.changed) {
            _hub.eventRegistry.DisplayAxes.fire(_bboxEnabled.value);
        }
    }
}
