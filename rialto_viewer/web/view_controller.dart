// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class ViewController implements IController {
    Hub _hub;
    bool isRunning;

    ViewController() {
        _hub = Hub.root;
        isRunning = false;

        _hub.modeController.register(this, ModeData.VIEW);

        // TODO
        //_hub.eventRegistry.MouseMove.subscribe(_handleMouseMove);
        //_hub.eventRegistry.MouseDown.subscribe(_handleMouseDown);
        //_hub.eventRegistry.MouseUp.subscribe(_handleMouseUp);
    }

    void startMode() {
    }

    void endMode() {
    }

    void _handleMouseMove(MouseData data) {
        if (!isRunning) return;
    }

    void _handleMouseDown(MouseData data) {
        if (!isRunning) return;

        assert(isRunning);
    }

    void _handleMouseUp(MouseData data) {
        if (!isRunning) return;
    }
}
