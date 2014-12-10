// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

library rialto.viewer.display_panel;

import 'dart:core';
import 'dart:html';
import 'package:polymer/polymer.dart';
import '../hub.dart';


@CustomTag('display-panel')
class DisplayPanel extends PolymerElement {
    @published bool axesChecked;
    @published bool bboxChecked;

    Hub _hub = Hub.root;

    DisplayPanel.created() : super.created();

    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
        _hub.displayPanel = this;
        _hub.eventRegistry.subscribeDisplayAxes((v) => axesChecked = v);
        _hub.eventRegistry.subscribeDisplayBbox((v) => bboxChecked = v);
        axesChecked = false;
        bboxChecked = false;
    }

    @override
    void detached() {
        super.detached();
    }

    void doAxesChecked(var mouseEvent) {
        _hub.eventRegistry.fireDisplayAxes(axesChecked);
    }

    void doBboxChecked(var mouseEvent) {
        _hub.eventRegistry.fireDisplayBbox(bboxChecked);
    }

    void doColorization(Event e, var detail, Node target) {
        _hub.colorizationDialog.openDialog();
    }
}
