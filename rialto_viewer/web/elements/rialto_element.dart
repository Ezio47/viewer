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
    Hub _hub;

    RialtoElement.created() : super.created();


    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
        _hub = Hub.root;
        _hub.rialtoElement = this;
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
        _hub.serverDialog.closeDialog();
    }

    void goHome(Event e, var detail, Node target) {
        _hub.eventRegistry.ChangeMode.fire(new ModeData(ModeData.MOVEMENT));
        //_hub.eventRegistry.MoveCameraHome.fire0();
    }

    void goColorize(Event e, var detail, Node target) {
        _hub.eventRegistry.ColorizeLayers.fire0();
    }

    void goAnnotate(Event e, var detail, Node target) {
        _hub.eventRegistry.ChangeMode.fire(new ModeData(ModeData.ANNOTATION));
    }

    void goSelect(Event e, var detail, Node target) {
        _hub.eventRegistry.ChangeMode.fire(new ModeData(ModeData.SELECTION));
    }

    void goMeasure(Event e, var detail, Node target) {
        _hub.eventRegistry.ChangeMode.fire(new ModeData(ModeData.MEASUREMENT));
    }
}
