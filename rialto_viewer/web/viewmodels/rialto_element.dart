// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class RialtoElement {
    Hub _hub;
    SpanElement _mouseCoords;
    InitScriptDialogVM _initScriptDialog;
    LayerManagerDialogVM _layerManager;
    CameraSettingsDialogVM _cameraSettingsDialog;
    AdvancedSettingsDialogVM _advancedSettingsDialog;
    ModalButtonsVM _modalButtons;
    AboutVM _aboutRialto;
    AboutVM _aboutCesium;

    int viewMode = ViewModeData.MODE_3D;

    Element _textWpsJobStatus;

    int _displayPrecision = 5;

    RialtoElement() {
        _hub = Hub.root;

        querySelector(
                "#homeWorldButton").onClick.listen(
                        (ev) => _hub.commands.updateCamera(new CameraData.fromMode(CameraData.WORLDVIEW_MODE)));
        querySelector(
                "#homeDataButton").onClick.listen(
                        (ev) => _hub.commands.updateCamera(new CameraData.fromMode(CameraData.DATAVIEW_MODE)));

        var modeButton2D = querySelector("#modeButton2D");
        var modeButton25D = querySelector("#modeButton25D");
        var modeButton3D = querySelector("#modeButton3D");
        modeButton2D.onClick.listen((ev) => _hub.commands.setViewMode(new ViewModeData(0)));
        modeButton25D.onClick.listen((ev) => _hub.commands.setViewMode(new ViewModeData(1)));
        modeButton3D.onClick.listen((ev) => _hub.commands.setViewMode(new ViewModeData(2)));

        _modalButtons = new ModalButtonsVM({
            querySelector("#viewModeButton"): new ModeData(ModeData.VIEW),
            querySelector("#annotateModeButton"): new ModeData(ModeData.ANNOTATION),
            querySelector("#measureModeButton"): new ModeData(ModeData.MEASUREMENT),
            querySelector("#viewshedModeButton"): new ModeData(ModeData.VIEWSHED)
        }, querySelector("#viewModeButton"));

        _initScriptDialog = new InitScriptDialogVM("#initScriptDialog");
        _layerManager = new LayerManagerDialogVM("#layerManagerDialog");
        _cameraSettingsDialog = new CameraSettingsDialogVM("#cameraSettingsDialog");
        _advancedSettingsDialog = new AdvancedSettingsDialogVM("#advancedSettingsDialog");

        _aboutRialto = new AboutVM("#aboutRialtoDialog");
        _aboutCesium = new AboutVM("#aboutCesiumDialog");

        _mouseCoords = querySelector("#textMouseCoords");
        _hub.events.MouseMove.subscribe(_handleUpdateCoords);

        _textWpsJobStatus = querySelector("#textWpsJobStatus");
        _hub.events.WpsJobUpdate.subscribe(_handleWpsJobUpdate);

        _hub.events.AdvancedSettingsChanged.subscribe((data) => _displayPrecision = data.displayPrecision);
    }

    String get viewModeString => "Mode / ${ViewModeData.name(viewMode)}";

    void _handleUpdateCoords(MouseData d) {
        var v = _hub.cesium.getMouseCoordinates(d.x, d.y);
        if (v == null) return;

        final double lon = v.longitude;
        final double lat = v.latitude;
        String s = "(${lon.toStringAsFixed(_displayPrecision)}, ${lat.toStringAsFixed(_displayPrecision)})";

        _mouseCoords.text = s;
    }

    String _wpsStatusString(int count) => "WPS pending: $count";

    void _handleWpsJobUpdate(WpsJobUpdateData data) {
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

        _textWpsJobStatus.text = "WPS jobs: $numActive";
    }
}
