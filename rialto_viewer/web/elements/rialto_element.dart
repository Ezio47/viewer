// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

library rialto.viewer.rialto_element;

import 'dart:core';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:paper_elements/paper_icon_button.dart';
import '../hub.dart';


@CustomTag('rialto-element')
class RialtoElement extends PolymerElement {

    Hub _hub = Hub.root;

    RialtoElement.created() : super.created();


    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
        Hub.root.mainWindow = this;
        Hub.root.serverDialogElement = $["server-dialog-element"];
        Hub.root.serverDialog = $["server-dialog"];
        Hub.root.colorizationDialogElement = $["colorization-dialog-element"];
        Hub.root.colorizationDialog = $["colorization-dialog"];
    }

    @override
    void detached() {
        super.detached();
    }

    void toggleCollapse2(Event e, var detail, Node target) {
        var e = $["collapse2"];
        var button = target as PaperIconButton;
        button.icon = e.opened ? "rialto-icons-small:chevdown" : "rialto-icons-small:chevup";
        e.toggle();
    }
    void toggleCollapse3(Event e, var detail, Node target) {
        var e = $["collapse3"];
        var button = target as PaperIconButton;
        button.icon = e.opened ? "rialto-icons-small:chevdown" : "rialto-icons-small:chevup";
        e.toggle();
    }
    void toggleCollapse4(Event e, var detail, Node target) {
        var e = $["collapse4"];
        var button = target as PaperIconButton;
        button.icon = e.opened ? "rialto-icons-small:chevdown" : "rialto-icons-small:chevup";
        e.toggle();
    }

    void toggleCollapse1(Event e, var detail, Node target) {
        var e = $["collapse1"];
        var button = target as PaperIconButton;
        button.icon = e.opened ? "rialto-icons-regular:chevdown" : "rialto-icons-regular:chevup";
        e.toggle();
    }
    void toggleCollapse5(Event e, var detail, Node target) {
        var e = $["collapse5"];
        var button = target as PaperIconButton;
        button.icon = e.opened ? "rialto-icons-regular:chevright" : "rialto-icons-regular:chevleft";
        e.toggle();
    }

    void closeServerDialog(Event e, var detail, Node target) {
        Hub.root.serverDialog.closeDialog();
    }

    void goHome(Event e, var detail, Node target) {
        _hub.eventRegistry.UpdateCameraEyePosition.fire(null);
        _hub.eventRegistry.UpdateCameraTargetPosition.fire(null);
    }


    void goColorize(Event e, var detail, Node target) {
        _hub.eventRegistry.ColorizeLayers.fire();
    }

}
