// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class Annotator {
    Hub _hub;
    SignalSubscription _mouseMoveSubscription;
    bool _running = false;

    Annotator() {
        _hub = Hub.root;

        _hub.eventRegistry.AnnotationMode.subscribe0(_handleModeChange);
        _mouseMoveSubscription = _hub.eventRegistry.MouseMove.subscribe0(_handleMouseMove);
    }

    void _handleModeChange() {
        if (_running) {
            _running = false;
            _end();
        } else {
            _running = true;
            _start();
        }
    }

    void _start() {
        _hub.eventRegistry.MouseMove.signal.exclusive = _mouseMoveSubscription;
    }

    void _end() {
        _hub.eventRegistry.MouseMove.signal.exclusive = null;
    }

    void _handleMouseMove() {
        print("d");
    }
}
