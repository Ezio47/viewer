// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class AnnotationController implements IController {
    Hub _hub;
    bool isRunning;

    Cartographic3 point1;
    Cartographic3 point2;

    AnnotationController() {
        _hub = Hub.root;
        isRunning = false;

        _hub.modeController.register(this, ModeData.ANNOTATION);

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

        print("annotation 1: ${Utils.printc(point1)}");
        print("annotation 2: ${Utils.printc(point2)}");

        Annotation a = new Annotation(point1, point2);

        _hub.annotations.add(a);

    //    _hub.cesium.createLabel("My house!", new Vector3(0.0,0.0,0.0));//-77.62549459934235, 38.833895271724664, 0.0));
        point1 = point2 = null;
    }
}

class Annotation {
    AnnotationShape shape;
    Cartographic3 _point1;
    Cartographic3 _point2;

    Annotation(Cartographic3 point1, Cartographic3 point2) {
        _point1 = point1;
        _point2 = point2;

        _fixCorners();

        _makeShape();
    }

    void _makeShape() {
        shape = new AnnotationShape(_point1, _point2);
    }

    void _fixCorners() {
        if (_point1.longitude > _point2.longitude) {
            var t = _point1.longitude;
            _point1.longitude = _point2.longitude;
            _point2..longitude = t;
        }
        if (_point1.latitude > _point2.latitude) {
            var t = _point1.latitude;
            _point1.latitude = _point2.latitude;
            _point2.latitude = t;
        }
        _point1.height = _point2.height = min(_point1.height, _point2.height);

        assert(_point1.longitude <= _point2.longitude);
        assert(_point1.latitude <= _point2.latitude);
        assert(_point1.height == _point2.height);
    }
}
