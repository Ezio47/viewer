// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class RialtoElement {
    Hub _hub;
    SpanElement _mouseCoords;
    InitScriptDialogVM _initScriptDialog;
    LayerManagerDialogVM _layerManager;
    SettingsDialogVM _advancedSettings;
    ModalButtonsVM _modalButtons;
    AboutVM _about, _aboutCesium;

    int viewMode = ViewModeData.MODE_3D;

    int _pendingWpsRequests = 0;
    Element _textWpsPending;

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
        _advancedSettings = new SettingsDialogVM("#advancedSettingsDialog");

        _about = new AboutVM("#aboutDialog");
        _aboutCesium = new AboutVM("#aboutCesiumDialog");

        _mouseCoords = querySelector("#textMouseCoords");
        _hub.events.MouseMove.subscribe(_updateCoords);

        _textWpsPending = querySelector("#textWpsPending");
        _hub.events.WpsRequestUpdate.subscribe(_handleWpsRequestUpdate);
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

    String get _wpsStatusString => "WPS pending: $_pendingWpsRequests";

    void _handleWpsRequestUpdate(WpsRequestUpdateData data) {
        if (data.count == 1) {
            ++_pendingWpsRequests;
            _textWpsPending.classes.remove("uk-text-muted");
            _textWpsPending.text = _wpsStatusString;
        } else if (data.count == -1) {
            --_pendingWpsRequests;
            if (_pendingWpsRequests == 0) {
                _textWpsPending.classes.add("uk-text-muted");
            }
            _textWpsPending.text = _wpsStatusString;
        } else {
            throw new ArgumentError("invalid WPS request count");
        }
    }
}
