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

    Cartographic3 _cloudMin;
    Cartographic3 _cloudMax;
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

        if (_renderSource.length > 0) {
            _cloudMin = new Cartographic3.fromVector3(_renderSource.min);
            _cloudMax = new Cartographic3.fromVector3(_renderSource.max);
            _cloudLen = _renderSource.len;

            camera.changeDataExtents(_cloudMin.longitude, _cloudMin.latitude, _cloudMax.longitude, _cloudMax.latitude);
        }

        if (_renderSource.numPoints > 0) {
            // axes model space is (0 .. 0.25 * cloudLen)
            final cloudLen14 = _cloudLen / 4.0;
            _axesShape = new AxesShape(_cloudMin, cloudLen14);
            _hub.shapesList.add(_axesShape);
        }

        if (_renderSource.numPoints > 0) {
            // bbox model space is (cloudMin....cloudMax)
            _bboxShape = new BboxShape(_cloudMin, _cloudMax);
            _hub.shapesList.add(_bboxShape);
        }

        {
            for (var rpc in _renderSource.renderablePointClouds) {
                var shapes = rpc.buildParticleSystem();
                shapes.forEach((shape) {
                    shape.isVisible = rpc.visible;
                    _hub.shapesList.add(shape);
                });
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
