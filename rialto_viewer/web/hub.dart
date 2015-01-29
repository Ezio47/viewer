// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

void log(o) {
    window.console.log(o);
}


class Hub {
    // singleton
    static Hub _root;

    // globals
    EventRegistry events;
    ModeController modeController;
    CesiumBridge cesium;
    Wps wps;

    // privates
    ViewController _viewController;
    AnnotationController _annotationController;
    MeasurementController _measurementController;
    SelectionController _selectionController;
    ViewshedController _viewshedController;
    BboxShape _bboxShape;
    Camera _camera;
    LayerManager _layerManager;

    // TODO: make private
    List<Annotation> annotations = new List<Annotation>();
    List<Measurement> measurements = new List<Measurement>();

    static Hub get root {
        assert(_root != null);
        return _root;
    }

    Hub() {
        assert(_root == null);
        _root = this;

        events = new EventRegistry();

        _layerManager = new LayerManager();

        cesium = new CesiumBridge('cesiumContainer');

        var rialtoElement = new RialtoElement();

        cesium.onMouseMove((x, y) => events.MouseMove.fire(new MouseData.fromXy(x, y)));
        cesium.onMouseDown((x, y, b) => events.MouseDown.fire(new MouseData.fromXyb(x, y, b)));
        cesium.onMouseUp((x, y, b) => events.MouseUp.fire(new MouseData.fromXyb(x, y, b)));
        cesium.onMouseWheel((d) => events.MouseWheel.fire(new WheelData.fromD(d.toDouble())));
        // onKeyDown...
        // onKeyUp...
        // onResize...

        events.DisplayBbox.subscribe(_handleDisplayBbox);

        events.LayersBboxChanged.subscribe(_handleLayersBboxChanged);

        modeController = new ModeController();
        _viewController = new ViewController();
        _annotationController = new AnnotationController();
        _measurementController = new MeasurementController();
        _selectionController = new SelectionController();
        _viewshedController = new ViewshedController();

        _camera = new Camera();

        events.ChangeMode.fire(new ModeData(ModeData.VIEW));

        events.LoadScript.subscribe(_handleLoadScript);
    }

    void _handleLayersBboxChanged(CartographicBbox box) {
        if (_bboxShape != null) _bboxShape.remove();
        if (box.isValid) {
            _bboxShape = new BboxShape(box.minimum, box.maximum);
        }
    }

    void _handleLoadScript(String url) {
        var s = new ConfigScript(url);
    }

    void _handleDisplayBbox(bool v) {
        if (_bboxShape == null) return;
        _bboxShape.isVisible = v;
    }

    void _handleDisplayLayer(DisplayLayerData data) {
        assert(data.layer != null);
        data.layer.changeVisibility(data.visible);
    }
}
