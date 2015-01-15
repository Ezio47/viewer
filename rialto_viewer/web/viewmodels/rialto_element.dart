// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class RialtoElement  {
    Hub _hub;
    SpanElement _mouseCoords;
    FileManagerDialogVM _fileManager;
    LayerManagerDialogVM _layerManager;
    SettingsDialogVM _advancedSettings;
    ModalButtonsVM _modalButtons;
    AboutVM _about;

    RialtoElement() {
        _hub = Hub.root;
        _hub.rialtoElement = this;

        _mouseCoords = querySelector("#textMouseCoords");

        querySelector("#homeWorldButton").onClick.listen((ev) => _hub.eventRegistry.UpdateCamera.fire(new CameraData.fromMode(1)));
        querySelector("#homeDataButton").onClick.listen((ev) => _hub.eventRegistry.UpdateCamera.fire(new CameraData.fromMode(2)));

        _modalButtons = new ModalButtonsVM({
            querySelector("#viewModeButton"): new ModeData(ModeData.VIEW),
            querySelector("#annotateModeButton"): new ModeData(ModeData.ANNOTATION),
            querySelector("#selectModeButton"): new ModeData(ModeData.SELECTION),
            querySelector("#measureModeButton"): new ModeData(ModeData.MEASUREMENT)
        }, querySelector("#viewModeButton"));

        _fileManager = new FileManagerDialogVM("fileManagerDialog");
        _layerManager = new LayerManagerDialogVM("layerManagerDialog");
        _advancedSettings = new SettingsDialogVM("advancedSettingsDialog");

        _about = new AboutVM("aboutDialog");

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
}
