// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class AdvancedSettingsVM extends ViewModel {
    bool axesChecked;
    bool bboxChecked;
    String eyePositionString;
    String targetPositionString;

    Hub _hub;

    AdvancedSettingsVM(DialogElement dialogElement, var dollar) : super(dialogElement, dollar) {

        _hub = Hub.root;
        _hub.eventRegistry.DisplayAxes.subscribe((v) => axesChecked = v);
        _hub.eventRegistry.DisplayBbox.subscribe((v) => bboxChecked = v);
        axesChecked = false;
        bboxChecked = false;
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
        var eyeVec = parseTriplet(eyePositionString);
        assert(false); // BUG: not supported again
    }
}
