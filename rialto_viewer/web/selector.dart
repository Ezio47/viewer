// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class Selector {
    Hub _hub;
    SignalSubscription _mouseMoveSubscription;
    SignalSubscription _mouseDownSubscription;
    SignalSubscription _mouseUpSubscription;
    bool running = false;
    Shape _selectedShape;
    Shape _possibleShape;
    int _pickedId;

    Selector() {
        _hub = Hub.root;

        _hub.eventRegistry.SelectionMode.subscribe0(_handleModeChange);
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
        print("selection mode on");

        _mouseMoveSubscription = _hub.eventRegistry.MouseMove.subscribe(_handleMouseMove);
        _hub.eventRegistry.MouseMove.signal.exclusive = _mouseMoveSubscription;

        _mouseDownSubscription = _hub.eventRegistry.MouseDown.subscribe(_handleMouseDown);
        _hub.eventRegistry.MouseDown.signal.exclusive = _mouseDownSubscription;

        _mouseUpSubscription = _hub.eventRegistry.MouseUp.subscribe(_handleMouseUp);
        _hub.eventRegistry.MouseUp.signal.exclusive = _mouseUpSubscription;

        _selectedShape = _possibleShape = null;
    }

    void _end() {
        _hub.eventRegistry.MouseMove.signal.exclusive = null;
        _hub.eventRegistry.MouseMove.unsubscribe(_mouseMoveSubscription);

        _hub.eventRegistry.MouseDown.signal.exclusive = null;
        _hub.eventRegistry.MouseDown.unsubscribe(_mouseDownSubscription);

        _hub.eventRegistry.MouseUp.signal.exclusive = null;
        _hub.eventRegistry.MouseUp.unsubscribe(_mouseUpSubscription);

        if (_selectedShape != null) {
            _selectedShape.highlight = false;
            _selectedShape = null;
        }

        print("selection mode off");
    }

    void _handleMouseMove(MouseData data) {
    }

    void _handleMouseDown(MouseData data) {
        assert(running);

        Point p = _hub.cameraInteractor.get2DCoords(data.x, data.y);

        List l = _hub.picker.find(p);
        if (l == null) return;
        _possibleShape = l[0];
        _pickedId = l[1];

    }

    void _handleMouseUp(MouseData data) {
        if (_possibleShape == null) {
            return;
        }

        _selectedShape.highlight = false;

        _selectedShape = _possibleShape;
        _selectedShape.highlight = true;
        _possibleShape = null;
    }
}
