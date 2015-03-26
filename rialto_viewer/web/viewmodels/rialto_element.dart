// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

/// code-behind for the index.html file
///
/// This class implements the functionality in Rialto's index.html file.
///
/// It is considered a "client" of the Rialto library, and so it should only access the viewer's
/// public interfaces.
class RialtoElement {
    Rialto _rialto;
    Element _mouseCoords;

    ViewModeCode viewMode = ViewModeCode.mode3D;

    Element _textWpsJobStatus;

    RialtoElement() {
        _rialto = Rialto.root;

        querySelector("#homeWorldButton").onClick.listen((ev) => _rialto.commands.zoomToWorld());
        querySelector("#homeDataButton").onClick.listen((ev) => _rialto.commands.zoomToLayer(null));

        querySelector("#viewshedCircleButton").onClick.listen((ev) => _rialto.commands.createViewshedCircle());
        querySelector("#viewshedComputeButton").onClick.listen((ev) => _rialto.commands.computeViewshed());

        querySelector("#linearMeasurementButton").onClick.listen((ev) => _rialto.commands.computeLinearMeasurement());
        querySelector("#areaMeasurementButton").onClick.listen((ev) => _rialto.commands.computeAreaMeasurement());

        querySelector("#dropPinButton").onClick.listen((ev) => _rialto.commands.dropPin());

        querySelector("#drawExtentButton").onClick.listen((ev) => _rialto.commands.drawExtent());

        var modeButton2D = querySelector("#modeButton2D");
        var modeButton25D = querySelector("#modeButton25D");
        var modeButton3D = querySelector("#modeButton3D");
        modeButton2D.onClick.listen((ev) => _rialto.commands.setViewMode(new ViewModeData(ViewModeCode.mode2D)));
        modeButton25D.onClick.listen((ev) => _rialto.commands.setViewMode(new ViewModeData(ViewModeCode.mode25D)));
        modeButton3D.onClick.listen((ev) => _rialto.commands.setViewMode(new ViewModeData(ViewModeCode.mode3D)));

        new LoadConfigurationDialog("#loadConfigurationDialog");
        new LayerManagerDialog("#layerManagerDialog");
        new LayerAdderDialog("#layerAdderDialog");
        new CameraSettingsDialog("#cameraSettingsDialog");
        new AdvancedSettingsDialog("#advancedSettingsDialog");

        new AboutDialog("#aboutRialtoDialog");
        new AboutDialog("#aboutCesiumDialog");
        new AboutDialog("#wpsStatusDialog");
        new AboutDialog("#logDialog");

        _mouseCoords = querySelector("#textMouseCoords");
        _rialto.events.MouseMove.subscribe(_handleUpdateCoords);

        _textWpsJobStatus = querySelector("#wpsStatusDialog_open");
        _handleWpsJobUpdate();
        _rialto.events.WpsJobUpdate.subscribe((_) => _handleWpsJobUpdate());
    }

    String get viewModeString => "Mode / ${ViewModeData.name[viewMode]}";

    void _handleUpdateCoords(MouseData d) {
        var v = _rialto.cesium.getMouseCoordinates(d.x, d.y);
        if (v == null) return;

        final precision = _rialto.displayPrecision;
        final double lon = v.longitude;
        final double lat = v.latitude;
        String s = "(${lon.toStringAsFixed(precision)}, ${lat.toStringAsFixed(precision)})";

        _mouseCoords.text = s;
    }

    void _handleWpsJobUpdate() {
        final int numActive = _rialto.wpsJobManager.numActive;

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

        _textWpsJobStatus.text = "Active jobs: ${_rialto.wpsJobManager.numActive}";

        String s = "";
        s += "Job count: ${_rialto.wpsJobManager.map.length}\n";

        _rialto.wpsJobManager.map.keys.forEach((id) => s += "\n----\n" + _rialto.wpsJobManager.map[id].dump());
        querySelector("#wpsStatusDialog_body").text = s;
    }
}
