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
    SpanElement _mouseCoords;

    RialtoElement.created() : super.created();


    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
        _hub = Hub.root;
        _hub.rialtoElement = this;

        ButtonElement goHome = $["goHome"];
        goHome.onClick.listen((ev) => _hub.eventRegistry.ChangeMode.fire(new ModeData(ModeData.MOVEMENT)));
        ButtonElement goColorize = $["goColorize"];
        goColorize.onClick.listen((ev) => _hub.eventRegistry.ColorizeLayers.fire0());
        ButtonElement goAnnotate = $["goAnnotate"];
        goAnnotate.onClick.listen((ev) => _hub.eventRegistry.ChangeMode.fire(new ModeData(ModeData.ANNOTATION)));
        ButtonElement goSelect = $["goSelect"];
        goSelect.onClick.listen((ev) => _hub.eventRegistry.ChangeMode.fire(new ModeData(ModeData.SELECTION)));
        ButtonElement goMeasure = $["goMeasure"];
        goMeasure.onClick.listen((ev) => _hub.eventRegistry.ChangeMode.fire(new ModeData(ModeData.MEASUREMENT)));

        _hub.eventRegistry.MouseMove.subscribe(_updateCoords);

        _mouseCoords = $["textMouseCoords"];
    }

    void _updateCoords(MouseData d)
    {
        var v = _hub.cesium.getMouseCoordinates(d.x, d.y);
        if (v == null) return;
        double lon = v.x;
        double lat = v.y;
        String s = "(${lon.toStringAsFixed(3)}, ${lat.toStringAsFixed(3)})";
        _mouseCoords.text = s;
        return;
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
}
