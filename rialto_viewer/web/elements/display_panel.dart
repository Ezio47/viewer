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
    @published bool showAxes = false;
    @published bool showBbox = false;
    @published bool axesbool1 = false;
    @published bool axesbool2 = false;
    @published bool axesbool3 = true;
    @published bool hasData;

    Hub _hub = Hub.root;

    DisplayPanel.created() : super.created();

    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
        _hub.displayPanel = this;
    }

    @override
    void detached() {
        super.detached();
    }


    void axesbool1Changed(var oldvalue) {
        _hub.commandRegistry.doToggleAxes(axesbool1);
        _hub.commandRegistry.doToggleBbox(axesbool2);
    }

    void axesbool2Changed(var oldvalue) {
        _hub.commandRegistry.doToggleAxes(axesbool1);
        _hub.commandRegistry.doToggleBbox(axesbool2);
    }

    void axesbool3Changed(var oldvalue) {
        _hub.commandRegistry.doToggleAxes(axesbool1);
        _hub.commandRegistry.doToggleBbox(axesbool2);
    }

    void toggleAxes(Event e, var detail, Node target) {
        var button = target as InputElement;
        _hub.commandRegistry.doToggleAxes(button.checked);
    }

    void toggleBbox(Event e, var detail, Node target) {
        var button = target as InputElement;
        _hub.commandRegistry.doToggleBbox(button.checked);
    }

}
