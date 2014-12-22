// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class Annotator {
    Hub _hub;
    SignalSubscription _mouseMoveSubscription;
    bool running = false;
    Shape _graphic;

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
        _mouseMoveSubscription = _hub.eventRegistry.MouseMove.subscribe(_handleMouseMove);
        _hub.eventRegistry.MouseMove.signal.exclusive = _mouseMoveSubscription;
    }

    void _end() {
        _hub.eventRegistry.MouseMove.signal.exclusive = null;
        _hub.eventRegistry.MouseMove.unsubscribe(_mouseMoveSubscription);
    }

    Vector3 point;
    Shape get graphic {
        /**
        if (point == null) return null;
        var gline = new Geometry();
        gline.vertices.add(point);
        gline.vertices.add(point * 1.1);
        var line = new Line(gline, new LineBasicMaterial(color: 0x0000ff));
        point = null;
        return line;
        ***/
        assert(false);
        return null;
    }

    void _handleMouseMove(MouseMoveData data) {
        /***
        //print("${new DateTime.now().millisecond}");
        assert(running);

        Vector3 ndc = _hub.mainRenderer.fromMouseToNdc(data.newX, data.newY);
        Vector3 world = _hub.mainRenderer.fromNdcToModel(ndc.x, ndc.y);
        point = world;
     ***/
        }
}
