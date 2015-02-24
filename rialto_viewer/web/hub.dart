// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

void log(obj) {
    if (obj == null) {
        window.console.log("** null passed to log() **");
    } else {
        window.console.log(obj.toString());
    }
}


class Hub {
    // singleton
    static Hub _root;

    // globals
    EventRegistry events;
    Commands commands;
    ModeController modeController;
    CesiumBridge cesium;
    JsBridge js;
    WpsService wps;
    LayerManager layerManager;

    // privates
    ViewController _viewController;
    AnnotationController _annotationController;
    MeasurementController _measurementController;
    ViewshedController _viewshedController;
    BboxShape _bboxShape;
    Camera _camera;

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

        js = new JsBridge();

        events = new EventRegistry();
        commands = new Commands();

        layerManager = new LayerManager();

        cesium = new CesiumBridge('cesiumContainer');

        var rialtoElement = new RialtoElement();

        cesium.onMouseMove((num x, num y) => events.MouseMove.fire(new MouseData.fromXy(x, y)));
        cesium.onMouseDown((num x, num y, int b) => events.MouseDown.fire(new MouseData.fromXyb(x, y, b)));
        cesium.onMouseUp((num x, num y, int b) => events.MouseUp.fire(new MouseData.fromXyb(x, y, b)));
        cesium.onMouseWheel((num d) => events.MouseWheel.fire(new WheelData.fromD(d)));
        // onKeyDown...
        // onKeyUp...
        // onResize...

        events.SetViewMode.subscribe(_handleSetViewMode);

        events.DisplayBbox.subscribe(_handleDisplayBbox);

        events.LayersBboxChanged.subscribe(_handleLayersBboxChanged);

        modeController = new ModeController();
        _viewController = new ViewController();
        _annotationController = new AnnotationController();
        _measurementController = new MeasurementController();
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

    void _handleSetViewMode(ViewModeData mode) {
        cesium.setViewMode(mode.mode);
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
        data.layer.visible = data.visible;
    }

    static void error(String text, {Map<String, dynamic> info: null, Object object: null}) {

        String s = text;

        if (!s.endsWith("\n")) {
            s += "\n";
        }

        if (info != null) {
            info.forEach((k,v) => s+= "$k: $v\n");
        }

        if (object != null) {
            s += 'Details: $object\n';
        }

        window.console.log(s);

        window.alert(s);
    }
}
