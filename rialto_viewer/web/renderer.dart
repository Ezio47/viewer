// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class Renderer {
    Hub _hub;

    RenderablePointCloudSet _renderSource;

    AxesShape _axesShape;
    BboxShape _bboxShape;

    List<Annotation> annotations = new List<Annotation>();
    List<Measurement> measurements = new List<Measurement>();

    Camera camera;

    Vector3 _cloudMin;
    Vector3 _cloudMax;
    Vector3 _cloudLen;

    bool updateNeeded;

    Renderer(RenderablePointCloudSet rpcSet) {
        _hub = Hub.root;

        _renderSource = rpcSet;

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

    void _update() {
        assert(updateNeeded);
        updateNeeded = false; // BUG: should this go at end? (race condition?)

        _hub.shapesList.forEach((s) => s.remove());
        _hub.shapesList.clear();

        _cloudMin = _renderSource.min;
        _cloudMax = _renderSource.max;
        _cloudLen = _renderSource.len;

        camera.changeDataExtents(_cloudMin.x, _cloudMin.y, _cloudMax.x, _cloudMax.y);

        if (_renderSource.length == 0) {
            // a reasonable default
            _cloudMin = new Vector3.zero();
            _cloudLen = new Vector3(1.0, 1.0, 1.0);
        }

        final cloudLen12 = _cloudLen / 2.0;
        final cloudLen14 = _cloudLen / 4.0;

        // TODO: set new camera defaults here

        {
            // axes model space is (0 .. 0.25 * cloudLen)
            _axesShape = new AxesShape(_cloudMin, cloudLen14);
            _hub.shapesList.add(_axesShape);
        }

        {
            // bbox model space is (cloudMin....cloudMax)
            _bboxShape = new BboxShape(_cloudMin, _cloudMax);
            _hub.shapesList.add(_bboxShape);
        }

        {
            for (var rpc in _renderSource.renderablePointClouds) {
                var obj = rpc.buildParticleSystem();
                obj.isVisible = rpc.visible;
                _hub.shapesList.add(obj);
            }
        }

        for (var annotation in annotations) {
            addAnnotationToScene(annotation);
        }

        for (var measurement in measurements) {
            addMeasurementToScene(measurement);
        }
    }

    void addAnnotationToScene(Annotation annotation) {
        _hub.shapesList.add(annotation.shape);
    }

    void addMeasurementToScene(Measurement measurement) {
        _hub.shapesList.add(measurement.shape);
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
