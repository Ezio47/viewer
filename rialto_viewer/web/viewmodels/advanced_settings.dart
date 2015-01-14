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

    Hub _hub;

    AdvancedSettingsVM(DialogElement dialogElement, var dollar) : super(dialogElement, dollar) {

        _hub = Hub.root;
        _hub.eventRegistry.DisplayAxes.subscribe((v) => axesChecked = v);
        _hub.eventRegistry.DisplayBbox.subscribe((v) => bboxChecked = v);
        axesChecked = false;
        bboxChecked = false;

        _eyeLon = new TextInputVM($["advancedSettingsDialog_eyeLon"], "0.0");
        _eyeLat = new TextInputVM($["advancedSettingsDialog_eyeLat"], "0.0");
        _eyeHeight = new TextInputVM($["advancedSettingsDialog_eyeHeight"], "0.0");
        _targetLon = new TextInputVM($["advancedSettingsDialog_targetLon"], "0.0");
        _targetLat = new TextInputVM($["advancedSettingsDialog_targetLat"], "0.0");
        _targetHeight = new TextInputVM($["advancedSettingsDialog_targetHeight"], "50000.0");
        _fov = new TextInputVM($["advancedSettingsDialog_fov"], "0.0");
        _upX = new TextInputVM($["advancedSettingsDialog_upX"], "0.0");
        _upY = new TextInputVM($["advancedSettingsDialog_upY"], "0.0");
        _upZ = new TextInputVM($["advancedSettingsDialog_upZ"], "0.0");
    }

    @override
    void _open() {}

    @override
    void _close(bool okay) {
        if (!okay) return;

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

        if (eyeOkay && targetOkay  && upOkay && fovOkay) {
            Vector3 eye = new Vector3(eyeLon, eyeLat, eyeHeight);
            Vector3 target = new Vector3(targetLon, targetLat, targetHeight);
            Vector3 up = new Vector3(upX, upY, upZ);

            var data = new CameraData(eye, target, up, fov);
            _hub.eventRegistry.UpdateCamera.fire(data);
        }

        assert(true);
    }

    void doAxesChecked(var mouseEvent) {
        _hub.eventRegistry.DisplayAxes.fire(axesChecked);
    }

    void doBboxChecked(var mouseEvent) {
        _hub.eventRegistry.DisplayBbox.fire(bboxChecked);
    }

    void doColorization(Event e, var detail, Node target) {
        //_hub.colorizationDialog.openDialog();
    }

    Vector3 parseTriplet(String triplet) {
        if (triplet == null || triplet.isEmpty) return null;
        var vec = new Vector3.zero();
        var list = triplet.split(",");
        try {
            vec.x = double.parse(list[0]);
            vec.y = double.parse(list[1]);
            vec.z = double.parse(list[2]);
        } catch (e) {
            // BUG: error check
            return null;
        }
        return vec;
    }

    void doCamera(Event e, var detail, Node target) {
        var eyeVec = _eyeLon.getValueAsDouble();
        assert(false); // BUG: not supported again
    }
}
