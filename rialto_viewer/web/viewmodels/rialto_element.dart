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

        var layerManagerDialog = $["layerManagerDialog"];
        _layerManager = new LayerManagerVM(layerManagerDialog, $);
        var layerSettingsDialog = $["layerSettingsDialog"];
        _layerSettings = new LayerSettingsVM(layerSettingsDialog, $);
        var advancedSettingsDialog = $["advancedSettingsDialog"];
        _advancedSettings = new AdvancedSettingsVM(advancedSettingsDialog, $);

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

        ButtonElement goLayerManager = $["goLayerManager"];
        goLayerManager.onClick.listen((ev) => _layerManager.open());

        ButtonElement goLayerSettings = $["goLayerSettings"];
        goLayerSettings.onClick.listen((ev) => _layerSettings.open());

        ButtonElement goAdvancedSettings = $["goAdvancedSettings"];
        goAdvancedSettings.onClick.listen((ev) => _advancedSettings.open());


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

