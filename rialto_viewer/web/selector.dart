// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class Selector implements IMode {
    Hub _hub;

    Shape _selectedShape;
    Shape _possibleShape;
    int _pickedId;
    bool isRunning;

    Selector() {
        _hub = Hub.root;
        isRunning = false;

        _hub.modeController.register(this, ModeData.SELECTION);

         _hub.eventRegistry.MouseMove.subscribe(_handleMouseMove);
         _hub.eventRegistry.MouseDown.subscribe(_handleMouseDown);
         _hub.eventRegistry.MouseUp.subscribe(_handleMouseUp);

        _selectedShape = _possibleShape = null;
    }

    void startMode() {
    }

    void endMode() {
        if (_selectedShape != null) {
            _selectedShape.isSelected = false;
            _selectedShape = null;
        }
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
        _pickedId = l[1];

    }

    void _handleMouseUp(MouseData data) {
        if (!isRunning) return;

        if (_possibleShape == null) {
            return;
        }

        _selectedShape.isSelected = false;

        _selectedShape = _possibleShape;
        _selectedShape.isSelected = true;
        _possibleShape = null;
    }
}
