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

    var e = querySelector("#logDialog_body");
    if (e != null) {
        e.text += obj.toString() + "\n";
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
    Camera camera;
    WpsJobManager wpsJobManager;

    int displayPrecision = 5;

    // privates
    BboxShape _bboxShape;

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

        js = new JsBridge(log);

        wpsJobManager = new WpsJobManager();

        events = new EventRegistry();
        commands = new Commands();

        layerManager = new LayerManager();
        modeController = new ModeController();

        cesium = new CesiumBridge('cesiumContainer');

        new RialtoElement();

        cesium.onMouseMove((num x, num y) => events.MouseMove.fire(new MouseData.fromXy(x, y)));
        cesium.onMouseDown((num x, num y, int b) => events.MouseDown.fire(new MouseData.fromXyb(x, y, b)));
        cesium.onMouseUp((num x, num y, int b) => events.MouseUp.fire(new MouseData.fromXyb(x, y, b)));
        cesium.onMouseWheel((num d) => events.MouseWheel.fire(new WheelData.fromD(d)));
        // onKeyDown...
        // onKeyUp...
        // onResize...

        events.LayersBboxChanged.subscribe(_handleLayersBboxChanged);

        new ViewController();
        new AnnotationController();
        new MeasurementController();
        new ViewshedController();

        camera = new Camera();

        commands.changeMode(new ModeData(ModeDataCodes.view));

        events.AdvancedSettingsChanged.subscribe((data) => _bboxShape.isVisible = data.showBbox);
        events.AdvancedSettingsChanged.subscribe((data) => displayPrecision = data.displayPrecision);
    }

    void _handleLayersBboxChanged(CartographicBbox box) {
        if (_bboxShape != null) _bboxShape.remove();
        if (box.isValid) {
            _bboxShape = new BboxShape(box.minimum, box.maximum);
        }
    }

    void displayBbox(bool v) {
        if (_bboxShape == null) return;
        _bboxShape.isVisible = v;
    }

    static void error(String text, {Map<String, dynamic> info: null, Object object: null}) {

        String s = text;

        if (!s.endsWith("\n")) {
            s += "\n";
        }

        if (info != null) {
            info.forEach((k, v) => s += "$k: $v\n");
        }

        if (object != null) {
            s += 'Details: $object\n';
        }

        window.console.log(s);

        window.alert(s);

        var e = querySelector("#logDialog_body");
        if (e != null) {
            e.text += s + "\n";
        }
    }
}
