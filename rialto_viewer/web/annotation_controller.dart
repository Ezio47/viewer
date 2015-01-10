// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class AnnotationController implements IController {
    Hub _hub;
    bool isRunning;

    Vector3 point1;
    Vector3 point2;

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

            Point p = _hub.cameraController.get2DCoords(data.x, data.y);

            List l = _hub.picker.find(p);
            if (l == null) return;
            var shape = l[0];
            var pickedId = l[1];

            if (shape is! CloudShape) return;
            point1 = shape.getPoint(pickedId);

        } else if (point2 == null) {
            Point p = _hub.cameraController.get2DCoords(data.x, data.y);

            List l = _hub.picker.find(p);
            if (l == null) return;
            var shape = l[0];
            var pickedId = l[1];

            if (shape is! CloudShape) return;
            point2 = shape.getPoint(pickedId);
        } else {
            // already have point, do nothing
        }
    }

    void _handleMouseUp(MouseData data) {
        if (!isRunning) return;

        if (point1 == null || point2 == null) {
            return;
        }

        print("annotation 1: ${Utils.printv(point1)}");
        print("annotation 2: ${Utils.printv(point2)}");

        Annotation a = new Annotation(point1, point2);

        _hub.mainRenderer.addAnnotationToScene(a);
        _hub.mainRenderer.annotations.add(a);

        point1 = point2 = null;
    }
}

class Annotation {
    AnnotationShape shape;
    Vector3 _point1;
    Vector3 _point2;

    Annotation(Vector3 point1, Vector3 point2) {
        _point1 = point1;
        _point2 = point2;

        _fixCorners();

        _makeShape();
    }

    void _makeShape() {
        shape = new AnnotationShape(_point1, _point2);
    }

    void _fixCorners() {
        if (_point1.x > _point2.x) {
            var t = _point1.x;
            _point1.x = _point2.x;
            _point2.x = t;
        }
        if (_point1.y > _point2.y) {
            var t = _point1.y;
            _point1.y = _point2.y;
            _point2.y = t;
        }
        _point1.z = _point2.z = min(_point1.z, _point2.z);

        assert(_point1.x <= _point2.x);
        assert(_point1.y <= _point2.y);
        assert(_point1.z == _point2.z);
    }
}
