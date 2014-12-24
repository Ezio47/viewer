// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class Selector implements IMode {
    Hub _hub;
    bool isRunning;

    Shape _possibleShape;
    int _possibleId;

    Selector() {
        _hub = Hub.root;
        isRunning = false;

        _hub.modeController.register(this, ModeData.SELECTION);

        _hub.eventRegistry.MouseMove.subscribe(_handleMouseMove);
        _hub.eventRegistry.MouseDown.subscribe(_handleMouseDown);
        _hub.eventRegistry.MouseUp.subscribe(_handleMouseUp);

        _possibleShape = null;
        _possibleId = -1;
    }

    void startMode() {
        _possibleShape = null;
        _possibleId = -1;
    }

    void endMode() {
        _possibleShape = null;
        _possibleId = -1;
    }

    void _handleMouseMove(MouseData data) {
        if (!isRunning) return;
    }

    void _handleMouseDown(MouseData data) {
        if (!isRunning) return;

        Point p = _hub.cameraController.get2DCoords(data.x, data.y);

        List l = _hub.picker.find(p);
        if (l == null) return;

        _possibleShape = l[0];
        _possibleId = l[1];
    }

    void _handleMouseUp(MouseData data) {
        if (!isRunning) return;

        if (_possibleShape == null) {
            return;
        }

        if (!_possibleShape.isSelectable) {
            _possibleShape = null;
            _possibleId = -1;
            return;
        }

        if (_possibleShape.isSelected) {
            if (_possibleShape is CloudShape) {
                CloudShape cs = _possibleShape;
                cs.selectedPoints.remove(_possibleId);
                if (cs.selectedPoints.length == 0) {
                    _possibleShape.isSelected = false;
                }
            } else {
                _possibleShape.isSelected = false;
            }
            _possibleShape = null;
            _possibleId = -1;
            return;
        }

        _possibleShape.isSelected = true;
        if (_possibleShape is CloudShape) {
            CloudShape cs = _possibleShape;
            cs.selectedPoints.add(_possibleId);
        }
        _possibleShape = null;
    }
}
