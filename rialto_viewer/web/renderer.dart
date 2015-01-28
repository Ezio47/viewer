// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class Renderer {
    Hub _hub;

    AxesShape _axesShape;
    BboxShape _bboxShape;

    List<Annotation> annotations = new List<Annotation>();
    List<Measurement> measurements = new List<Measurement>();

    Camera camera;

    bool updateNeeded;

    Renderer() {
        _hub = Hub.root;

        camera = new Camera();

        _hub.eventRegistry.DisplayAxes.subscribe(_handleDisplayAxes);
        _hub.eventRegistry.DisplayBbox.subscribe(_handleDisplayBbox);

        updateNeeded = true;
    }


    void checkUpdate(dynamic theScene, dynamic theTime) {
        if (updateNeeded) {
            _update();
        }
    }

    void forceUpdate() => _update();

    void _update() {
        //assert(updateNeeded);
        updateNeeded = false; // BUG: should this go at end? (race condition?)

        // BUG: only do these things if any of the layer manager has changed

        var box = _hub.layerManager.bbox;

        if (_hub.layerManager.layers.length > 0 && box.isValid) {
            camera.changeDataExtents(box);

            // axes model space is (0 .. 0.25 * cloudLen)
            final len14 = box.length / 4.0;
            if (_axesShape != null) _axesShape.remove();
            _axesShape = new AxesShape(box.minimum, len14);

            // bbox model space is (cloudMin....cloudMax)
            if (_bboxShape != null) _bboxShape.remove();
            _bboxShape = new BboxShape(box.minimum, box.maximum);
        }
    }

    void _handleDisplayAxes(bool v) {
        if (_axesShape == null) return;
        _axesShape.isVisible = v;
    }

    void _handleDisplayBbox(bool v) {
        if (_bboxShape == null) return;
        _bboxShape.isVisible = v;
    }
}
