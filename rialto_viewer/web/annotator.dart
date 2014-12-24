// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class Annotator {
    Hub _hub;
    SignalSubscription _mouseMoveSubscription;
    SignalSubscription _mouseDownSubscription;
    SignalSubscription _mouseUpSubscription;
    bool running = false;

    Vector3 point1;
    Vector3 point2;

    Annotator() {
        _hub = Hub.root;

        _hub.eventRegistry.AnnotationMode.subscribe0(_handleModeChange);
    }

    void _handleModeChange() {
        if (running) {
            running = false;
            _end();
        } else {
            running = true;
            _start();
        }
    }

    void _start() {
        print("annotaion mode on");

        _mouseMoveSubscription = _hub.eventRegistry.MouseMove.subscribe(_handleMouseMove);
        _hub.eventRegistry.MouseMove.signal.exclusive = _mouseMoveSubscription;

        _mouseDownSubscription = _hub.eventRegistry.MouseDown.subscribe(_handleMouseDown);
        _hub.eventRegistry.MouseDown.signal.exclusive = _mouseDownSubscription;

        _mouseUpSubscription = _hub.eventRegistry.MouseUp.subscribe(_handleMouseUp);
        _hub.eventRegistry.MouseUp.signal.exclusive = _mouseUpSubscription;

        point1 = point2 = null;
    }

    void _end() {
        _hub.eventRegistry.MouseMove.signal.exclusive = null;
        _hub.eventRegistry.MouseMove.unsubscribe(_mouseMoveSubscription);

        _hub.eventRegistry.MouseDown.signal.exclusive = null;
        _hub.eventRegistry.MouseDown.unsubscribe(_mouseDownSubscription);

        _hub.eventRegistry.MouseUp.signal.exclusive = null;
        _hub.eventRegistry.MouseUp.unsubscribe(_mouseUpSubscription);

        print("annotaion mode off");
    }

    void _handleMouseMove(MouseData data) {
    }

    void _handleMouseDown(MouseData data) {
        assert(running);

        if (point1 == null) {

            Point p = _hub.cameraInteractor.get2DCoords(data.x, data.y);

            List l = _hub.picker.find(p);
            if (l == null) return;
            var shape = l[0];
            var pickedId = l[1];

            if (shape is! CloudShape) return;
            point1 = shape.getPoint(pickedId);

        } else if (point2 == null) {
            Point p = _hub.cameraInteractor.get2DCoords(data.x, data.y);

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
        if (point1 == null || point2 == null) {
            return;
        }

        print("ONE: ${Utils.printv(point1)}");
        print("TWO: ${Utils.printv(point2)}");

        Annotation a = new Annotation(point1, point2);

        _hub.mainRenderer.annotations.add(a);
        _hub.mainRenderer.update();

        point1 = point2 = null;
    }
}
