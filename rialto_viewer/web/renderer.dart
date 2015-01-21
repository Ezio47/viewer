// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class Renderer {
    Hub _hub;

    PointCloudSet _pointClouds;

    AxesShape _axesShape;
    BboxShape _bboxShape;

    List<Annotation> annotations = new List<Annotation>();
    List<Measurement> measurements = new List<Measurement>();

    Camera camera;

    Cartographic3 _cloudMin;
    Cartographic3 _cloudMax;
    Vector3 _cloudLen;

    bool updateNeeded;

    Renderer(PointCloudSet rpcSet) {
        _hub = Hub.root;

        _pointClouds = rpcSet;

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

        if (_pointClouds.length > 0) {
            _cloudMin = new Cartographic3.fromVector3(_pointClouds.min);
            _cloudMax = new Cartographic3.fromVector3(_pointClouds.max);
            _cloudLen = _pointClouds.len;

            camera.changeDataExtents(_cloudMin.longitude, _cloudMin.latitude, _cloudMax.longitude, _cloudMax.latitude);
        }

        if (_pointClouds.numPoints > 0) {
            // axes model space is (0 .. 0.25 * cloudLen)
            final cloudLen14 = _cloudLen / 4.0;
            if (_axesShape != null) _axesShape.remove();
            _axesShape = new AxesShape(_cloudMin, cloudLen14);
        }

        if (_pointClouds.numPoints > 0) {
            // bbox model space is (cloudMin....cloudMax)
            if (_bboxShape != null) _bboxShape.remove();
            _bboxShape = new BboxShape(_cloudMin, _cloudMax);
        }

        for (var pointCloud in _pointClouds.list) {
            //
        }

        for (var annotation in annotations) {
            //
        }

        for (var measurement in measurements) {
            //
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
