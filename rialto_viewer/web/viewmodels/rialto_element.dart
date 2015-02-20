// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class RialtoElement  {
    Hub _hub;
    SpanElement _mouseCoords;
    InitScriptDialogVM _initScriptDialog;
    LayerManagerDialogVM _layerManager;
    SettingsDialogVM _advancedSettings;
    ModalButtonsVM _modalButtons;
    AboutVM _about;

    int viewMode = ViewModeData.MODE_3D;

    RialtoElement() {
        _hub = Hub.root;

        _mouseCoords = querySelector("#textMouseCoords");

        querySelector("#homeWorldButton").onClick.listen((ev) => _hub.events.UpdateCamera.fire(new CameraData.fromMode(CameraData.WORLDVIEW_MODE)));
        querySelector("#homeDataButton").onClick.listen((ev) => _hub.events.UpdateCamera.fire(new CameraData.fromMode(CameraData.DATAVIEW_MODE)));

        var modeButton = querySelector("#modeButton");
        modeButton.text = viewModeString;
        modeButton.onClick.listen((ev) {
            viewMode = (viewMode + 1) % 3;
            modeButton.text = viewModeString;
            _hub.events.SetViewMode.fire(new ViewModeData(viewMode));
        });

        _modalButtons = new ModalButtonsVM({
            querySelector("#viewModeButton"): new ModeData(ModeData.VIEW),
            querySelector("#annotateModeButton"): new ModeData(ModeData.ANNOTATION),
            querySelector("#measureModeButton"): new ModeData(ModeData.MEASUREMENT),
            querySelector("#viewshedModeButton"): new ModeData(ModeData.VIEWSHED)
        }, querySelector("#viewModeButton"));

        _initScriptDialog = new InitScriptDialogVM("#initScriptDialog");
        _layerManager = new LayerManagerDialogVM("#layerManagerDialog");
        _advancedSettings = new SettingsDialogVM("#advancedSettingsDialog");

        _about = new AboutVM("#aboutDialog");

        _hub.events.MouseMove.subscribe(_updateCoords);
    }

    String get viewModeString => "Mode / ${ViewModeData.name(viewMode)}";

    void _updateCoords(MouseData d) {
        var v = _hub.cesium.getMouseCoordinates(d.x, d.y);
        if (v == null) return;
        double lon = v.longitude;
        double lat = v.latitude;
        String s = "(${lon.toStringAsFixed(5)}, ${lat.toStringAsFixed(5)})";
        _mouseCoords.text = s;
        return;
    }
}
