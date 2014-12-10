// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

library rialto.viewer.render_panel;

import 'dart:core';
import 'package:polymer/polymer.dart';
import '../hub.dart';


@CustomTag('render-panel')
class RenderPanel extends PolymerElement {

    Hub _hub;

    RenderPanel.created() : super.created();

    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
        _hub = Hub.root;

        if (id == "main") {
            _hub.mainRenderPanel = this;
        } else {
            assert(id == "nav");
            _hub.navRenderPanel = this;
        }
    }

    @override
    void detached() {
        super.detached();
    }
}
