// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

library rialto.viewer.status_element;

import 'dart:core';
import 'dart:html';
import 'package:polymer/polymer.dart';
import '../hub.dart';


@CustomTag('status-panel')
class StatusPanel extends PolymerElement {
    @observable double mousePositionX;
    @observable double mousePositionY;
    @observable double mousePositionZ;

    Hub _hub;

    StatusPanel.created() : super.created();

    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
        _hub = Hub.root;

        _hub.eventRegistry.MouseGeoCoords.subscribe((data) {
            mousePositionX = data.x;
            mousePositionY = data.y;
            mousePositionZ = data.z;
        });
    }

    @override
    void detached() {
        super.detached();
    }

    void aboutbox(Event e, var detail, Node target) {
        window.alert("Copyright © RadiantBlue 2014.");
    }
}
