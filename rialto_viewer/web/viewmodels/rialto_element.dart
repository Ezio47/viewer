// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

library rialto.viewer.rialto_element;

import 'dart:core';
import 'dart:html';
import 'package:polymer/polymer.dart';
import '../rialto.dart';


@CustomTag('rialto-element')
class RialtoElement extends PolymerElement {
    Hub _hub;
    SpanElement _mouseCoords;
    LayerManagerVM _layerManager;
    LayerSettingsVM _layerSettings;
    AdvancedSettingsVM _advancedSettings;
    ModalButtonsVM _modalButtons;

    RialtoElement.created() : super.created();

    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
        _hub = Hub.root;
        _hub.rialtoElement = this;

        _mouseCoords = $["textMouseCoords"];

        $["homeButton"].onClick.listen((ev) => _hub.eventRegistry.UpdateCamera.fire(null));

        _modalButtons = new ModalButtonsVM({
            $["viewModeButton"]: new ModeData(ModeData.VIEW),
            $["annotateModeButton"]: new ModeData(ModeData.ANNOTATION),
            $["selectModeButton"]: new ModeData(ModeData.SELECTION),
            $["measureModeButton"]: new ModeData(ModeData.MEASUREMENT)
        }, $["viewModeButton"]);

        _layerManager = new LayerManagerVM($["layerManagerDialog"], $);
        _layerSettings = new LayerSettingsVM($["layerSettingsDialog"], $);
        _advancedSettings = new AdvancedSettingsVM($["advancedSettingsDialog"], $);

        _hub.eventRegistry.MouseMove.subscribe(_updateCoords);
    }

    void _updateCoords(MouseData d) {
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

    void aboutbox(Event e, var detail, Node target) {
        window.alert("Copyright © RadiantBlue 2014.");
    }
}
