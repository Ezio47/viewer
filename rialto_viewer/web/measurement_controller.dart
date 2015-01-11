// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class MeasurementController implements IController {
    Hub _hub;
    bool isRunning;

    Vector3 point1;
    Vector3 point2;

    MeasurementController() {
        _hub = Hub.root;
        isRunning = false;

        _hub.modeController.register(this, ModeData.MEASUREMENT);

        _hub.eventRegistry.MouseMove.subscribe(_handleMouseMove);
        _hub.eventRegistry.MouseDown.subscribe(_handleMouseDown);
        _hub.eventRegistry.MouseUp.subscribe(_handleMouseUp);
    }

    void startMode() {
        point1 = point2 = null;
    }

    void endMode() {
    }

    void _handleMouseMove(MouseData data) {
        if (!isRunning) return;
    }

    void _handleMouseDown(MouseData data) {
        if (!isRunning) return;

        assert(isRunning);

        if (point1 == null) {

            point1 = _hub.cesium.getMouseCoordinates();
            if (point1 == null) return;

        } else if (point2 == null) {
            point2 = _hub.cesium.getMouseCoordinates();
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

        print("Distance from ${Utils.printv(point1)} to ${Utils.printv(point2)}");

        Measurement m = new Measurement(point1, point2);

        _hub.mainRenderer.addMeasurementToScene(m);
        _hub.mainRenderer.measurements.add(m);

        point1 = point2 = null;
    }
}

class Measurement {
    MeasurementShape shape;
    Vector3 _point1;
    Vector3 _point2;

    Measurement(Vector3 point1, Vector3 point2) {
        _point1 = point1;
        _point2 = point2;

        _makeShape();
    }

    void _makeShape() {
        shape = new MeasurementShape(_point1, _point2);
    }
}
