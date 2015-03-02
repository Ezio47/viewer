// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class ViewshedController implements IController {
    Hub _hub;
    bool isRunning;

    Cartographic3 point1;
    Cartographic3 point2;

    ViewshedController() {
        _hub = Hub.root;
        isRunning = false;

        _hub.modeController.register(this, ModeData.VIEWSHED);

        _hub.events.MouseMove.subscribe(_handleMouseMove);
        _hub.events.MouseDown.subscribe(_handleMouseDown);
        _hub.events.MouseUp.subscribe(_handleMouseUp);
    }

    void startMode() {
        point1 = point2 = null;
    }

    void endMode() {
    }

    void _handleMouseMove(MouseData data) {
    }

    void _handleMouseDown(MouseData data) {
        if (!isRunning) return;

        assert(isRunning);

        if (point1 == null) {

            point1 = _hub.cesium.getMouseCoordinates(data.x, data.y);
            if (point1 == null) return;

        } else if (point2 == null) {
            point2 = _hub.cesium.getMouseCoordinates(data.x, data.y);
            if (point2 == null) return;

        } else {
            // already have point, do nothing
        }
    }

    void _handleMouseUp(MouseData data) {
        if (!isRunning) return;

        if (point1 == null || point2 == null) {
            return;
        }

        log("viewshed pt1: ${Utils.toString_Cartographic3(point1)}");
        log("viewshed pt2: ${Utils.toString_Cartographic3(point2)}");

        Viewshed a = new Viewshed(point1, point2);

        var params = [];
        params[0] = "Viewshed";
        params[1] = {
            "pt1Lon": point1.longitude,
            "pt1Lat": point1.latitude,
            "pt2Lon": point2.longitude,
            "pt2Lat": point2.latitude
        };
        params[2] = ["resultLon"];

        _hub.commands.wpsRequest(new WpsRequestData(WpsRequestData.EXECUTE_PROCESS, params));

        point1 = point2 = null;
    }
}

class Viewshed {
    ViewshedShape shape;
    Cartographic3 _point1;
    Cartographic3 _point2;

    Viewshed(Cartographic3 point1, Cartographic3 point2) {
        _point1 = point1;
        _point2 = point2;

        _makeShape();
    }

    void _makeShape() {
        shape = new ViewshedShape(_point1, _point2);
    }
}
