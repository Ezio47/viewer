// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class RialtoElement {
    Hub _hub;
    Element _mouseCoords;

    ViewModeCode viewMode = ViewModeCode.mode3D;

    Element _textWpsJobStatus;

    RialtoElement() {
        _hub = Hub.root;

        querySelector(
                "#homeWorldButton").onClick.listen(
                        (ev) => _hub.commands.updateCamera(new CameraData.fromMode(CameraViewMode.worldviewMode)));
        querySelector(
                "#homeDataButton").onClick.listen(
                        (ev) => _hub.commands.updateCamera(new CameraData.fromMode(CameraViewMode.dataviewMode)));

        var modeButton2D = querySelector("#modeButton2D");
        var modeButton25D = querySelector("#modeButton25D");
        var modeButton3D = querySelector("#modeButton3D");
        modeButton2D.onClick.listen((ev) => _hub.commands.setViewMode(new ViewModeData(ViewModeCode.mode2D)));
        modeButton25D.onClick.listen((ev) => _hub.commands.setViewMode(new ViewModeData(ViewModeCode.mode25D)));
        modeButton3D.onClick.listen((ev) => _hub.commands.setViewMode(new ViewModeData(ViewModeCode.mode3D)));

        new ModalButtonsVM({
            querySelector("#viewModeButton"): new ModeData(ModeDataCodes.view),
            querySelector("#annotateModeButton"): new ModeData(ModeDataCodes.annotation),
            querySelector("#measureModeButton"): new ModeData(ModeDataCodes.measurement),
            querySelector("#viewshedModeButton"): new ModeData(ModeDataCodes.viewshed)
        }, querySelector("#viewModeButton"));

        new LoadConfigurationDialogVM("#loadConfigurationDialog");
        new LayerManagerDialogVM("#layerManagerDialog");
        new CameraSettingsDialogVM("#cameraSettingsDialog");
        new AdvancedSettingsDialogVM("#advancedSettingsDialog");

        new AboutVM("#aboutRialtoDialog");
        new AboutVM("#aboutCesiumDialog");
        new AboutVM("#wpsStatusDialog");
        new AboutVM("#logDialog");

        _mouseCoords = querySelector("#textMouseCoords");
        _hub.events.MouseMove.subscribe(_handleUpdateCoords);

        new ColorizerDialogVM("#colorizerDialog");

        _textWpsJobStatus = querySelector("#wpsStatusDialog_open");
        _handleWpsJobUpdate();
        _hub.events.WpsJobUpdate.subscribe((_) => _handleWpsJobUpdate());
    }

    String get viewModeString => "Mode / ${ViewModeData.name[viewMode]}";

    void _handleUpdateCoords(MouseData d) {
        var v = _hub.cesium.getMouseCoordinates(d.x, d.y);
        if (v == null) return;

        final precision = _hub.displayPrecision;
        final double lon = v.longitude;
        final double lat = v.latitude;
        String s = "(${lon.toStringAsFixed(precision)}, ${lat.toStringAsFixed(precision)})";

        _mouseCoords.text = s;
    }

    void _handleWpsJobUpdate() {
        final int numActive = _hub.wpsJobManager.numActive;

        if (numActive < 0) {
            throw new ArgumentError("invalid WPS request count");
        }

        if (numActive == 0) {
            if (!_textWpsJobStatus.classes.contains("uk-text-muted")) {
                _textWpsJobStatus.classes.add("uk-text-muted");
            }
        } else {
            if (_textWpsJobStatus.classes.contains("uk-text-muted")) {
                _textWpsJobStatus.classes.remove("uk-text-muted");
            }
        }

        _textWpsJobStatus.text = "Active jobs: ${_hub.wpsJobManager.numActive}";

        String s = "";
        s += "Job count: ${_hub.wpsJobManager.map.length}\n";

        _hub.wpsJobManager.map.keys.forEach((id) => s += "\n----\n" + _hub.wpsJobManager.map[id].dump());
        querySelector("#wpsStatusDialog_body").text = s;
    }
}
