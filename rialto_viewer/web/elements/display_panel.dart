// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

library rialto.viewer.display_panel;

import 'dart:core';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:vector_math/vector_math.dart';
import '../hub.dart';


@CustomTag('display-panel')
class DisplayPanel extends PolymerElement {
    @published bool axesChecked;
    @published bool bboxChecked;
    @published String eyePositionString;
    @published String targetPositionString;

    Hub _hub;

    DisplayPanel.created() : super.created();

    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
        _hub = Hub.root;
        _hub.eventRegistry.DisplayAxes.subscribe((v) => axesChecked = v);
        _hub.eventRegistry.DisplayBbox.subscribe((v) => bboxChecked = v);
        axesChecked = false;
        bboxChecked = false;
    }

    @override
    void detached() {
        super.detached();
    }

    void doAxesChecked(var mouseEvent) {
        _hub.eventRegistry.DisplayAxes.fire(axesChecked);
    }

    void doBboxChecked(var mouseEvent) {
        _hub.eventRegistry.DisplayBbox.fire(bboxChecked);
    }

    void doColorization(Event e, var detail, Node target) {
        _hub.colorizationDialog.openDialog();
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
