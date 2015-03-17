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
    CesiumBridge cesium;
    JsBridge js;
    WpsService wps;
    LayerManager layerManager;
    Camera camera;
    WpsJobManager wpsJobManager;

    int displayPrecision = 5;

    // privates
    BboxShape _bboxShape;

    List viewshedCircles = new List();

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

        cesium = new CesiumBridge('cesiumContainer');

        new RialtoElement();

        cesium.onMouseMove((num x, num y) => events.MouseMove.fire(new MouseData.fromXy(x, y)));

        events.LayersBboxChanged.subscribe(_handleLayersBboxChanged);

        camera = new Camera();

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

    double computeLength(var positions) {
        double dist = 0.0;
        var numPoints = positions.length / 3;
        for (var i=0; i<numPoints - 1; i++) {
            double x1 = positions[i*3];
            double y1 = positions[i*3+1];
            double x2 = positions[(i+1)*3];
            double y2 = positions[(i+1)*3+1];
            dist += cesium.cartographicDistance(x1, y1, x2, y2);
        }
        return dist;
    }

    double computeArea(var positions) {
        var area = 0.0;
        var numPoints = positions.length / 3;
        for (var i=0; i<numPoints; i++) {
            var j = (i < numPoints - 1) ? i+1 : 0;
            double x1 = positions[i*3];
            double y1 = positions[i*3+1];
            double x2 = positions[j*3];
            double y2 = positions[j*3+1];
            var t = x1 * y2 - y1 * x2;
            area += t;
        }
        area = area / 2.0;
        if (area < 0.0) area = -area;
        return area;

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
