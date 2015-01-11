// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class SelectionController implements IController {
    Hub _hub;
    bool isRunning;

    Shape _possibleShape;

    SelectionController() {
        _hub = Hub.root;
        isRunning = false;

        _hub.modeController.register(this, ModeData.SELECTION);

        _hub.eventRegistry.MouseMove.subscribe(_handleMouseMove);
        _hub.eventRegistry.MouseDown.subscribe(_handleMouseDown);
        _hub.eventRegistry.MouseUp.subscribe(_handleMouseUp);

        _possibleShape = null;
    }

    void startMode() {
        _possibleShape = null;
    }

    void endMode() {
        _possibleShape = null;
    }

    void _handleMouseMove(MouseData data) {
        if (!isRunning) return;
    }

    void _handleMouseDown(MouseData data) {
        if (!isRunning) return;

        Shape s = _hub.picker.getCurrentShape();
        if (s != null) _possibleShape = s;
    }

    void _handleMouseUp(MouseData data) {
        if (!isRunning) return;

        if (_possibleShape == null) {
            return;
        }

        if (!_possibleShape.isSelectable) {
            _possibleShape = null;
            return;
        }

        if (_possibleShape.isSelected) {
            // unselect
            _possibleShape.isSelected = false;
            _possibleShape = null;
            return;
        }

        _possibleShape.isSelected = true;
        _possibleShape = null;
    }
}
