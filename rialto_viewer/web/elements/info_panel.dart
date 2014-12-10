// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

library rialto.viewer.info_panel;

import 'dart:core';
import 'package:polymer/polymer.dart';
import '../hub.dart';


@CustomTag('info-panel')
class InfoPanel extends PolymerElement {
    @published double minx, maxx, miny, maxy, minz, maxz;
    @published bool hasData = true;
    @published int numPoints;

    Hub _hub;

    InfoPanel.created() : super.created();

    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
        _hub = Hub.root;

        _hub.eventRegistry.OpenFileCompleted.subscribe((_) {
            minx = _hub.renderablePointCloudSet.min.x;
            maxx = _hub.renderablePointCloudSet.max.x;
            miny = _hub.renderablePointCloudSet.min.y;
            maxy = _hub.renderablePointCloudSet.max.y;
            minz = _hub.renderablePointCloudSet.min.z;
            maxz = _hub.renderablePointCloudSet.max.z;
            numPoints = _hub.renderablePointCloudSet.numPoints;
        });
    }

    @override
    void detached() {
        super.detached();
    }



}
