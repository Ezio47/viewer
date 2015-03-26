// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


/// Main, public class for the viewer
///
/// All external calls to the Rialto viewer, e.g. from main or from the UI pieces,
/// should go through this object.
///
/// This is explcitly a singleton.
///
/// (this class formerly known as "Hub", and some references to it still use that name)
class RialtoBackend {
    // globals
    EventRegistry events;
    Commands commands;
    CesiumBridge cesium;
    JsBridge js;
    WpsService wps;
    LayerManager layerManager;
    WpsJobManager wpsJobManager;

    int displayPrecision = 5;

    List viewshedCircles = new List();

    /// Creates the instance of the viewer backend
    RialtoBackend() {
        js = new JsBridge(log);

        wpsJobManager = new WpsJobManager(this);

        events = new EventRegistry();
        commands = new Commands(this);

        layerManager = new LayerManager(this);

        cesium = new CesiumBridge('cesiumContainer');

        cesium.onMouseMove((num x, num y) => events.MouseMove.fire(new MouseData.fromXy(x, y)));

        events.AdvancedSettingsChanged.subscribe((data) => displayPrecision = data.displayPrecision);
    }

    /// Compute linear length of a set of points
    ///
    /// Stub for future work
    double computeLength(var positions) {
        double dist = 0.0;
        var numPoints = positions.length / 3;
        for (var i = 0; i < numPoints - 1; i++) {
            double x1 = positions[i * 3];
            double y1 = positions[i * 3 + 1];
            double x2 = positions[(i + 1) * 3];
            double y2 = positions[(i + 1) * 3 + 1];
            dist += cesium.cartographicDistance(x1, y1, x2, y2);
        }
        return dist;
    }

    /// Compute area of a set of points
    ///
    /// Stub for future work.
    double computeArea(var positions) {
        var area = 0.0;
        var numPoints = positions.length / 3;
        for (var i = 0; i < numPoints; i++) {
            var j = (i < numPoints - 1) ? i + 1 : 0;
            double x1 = positions[i * 3];
            double y1 = positions[i * 3 + 1];
            double x2 = positions[j * 3];
            double y2 = positions[j * 3 + 1];
            var t = x1 * y2 - y1 * x2;
            area += t;
        }
        area = area / 2.0;
        if (area < 0.0) area = -area;
        return area;

    }

    /// Zooms the viewer to the given position
    Future zoomTo(Cartographic3 eyePosition, Cartographic3 targetPosition, Cartesian3 upDirection, double fov) {

        cesium.lookAt(eyePosition, targetPosition, upDirection, fov);

        return new Future.value();
    }

    /// Zooms the viewer to the given [layer]
    ///
    /// Zooms to the last layer in the system, if [layer] is null.
    ///
    /// If [layer] can't be zoomed to, e.g. because it doesn't have an explicit bbox,
    /// the function does nothing and returns.
    ///
    /// Note we have hard-coded some arbitrary rules as to how to position the camera relative to
    /// the bbox of the [layer].
    Future zoomToLayer(Layer layer) {
        if (layer == null) {
            layer = layerManager.layers.last;
        }

        if (layer == null || layer.bbox == null) {
            return new Future.value();
        }

        var bbox = layer.bbox;
        double west = bbox.west;
        double south = bbox.south;
        double east = bbox.east;
        double north = bbox.north;

        double centerLon = east + (west - east) / 2.0;
        double centerLat = south + (north - south) / 2.0;

        var targetPosition = new Cartographic3(centerLon, centerLat, 0.0);

        var h = max(west - east, north - south) * 1000.0;
        var eyePosition = new Cartographic3(centerLon, centerLat, h);


        final Cartesian3 upDirection = new Cartesian3(0.0, 0.0, 1.0);
        final double fov = 60.0;

        cesium.lookAt(eyePosition, targetPosition, upDirection, fov);

        return new Future.value();
    }

    /// Zooms the viewer to a global view, positioned somewhere above the western hemisphere.
    Future zoomToWorld() {
        cesium.goHome();
        return new Future.value();
    }

    /// Error reporting function for all of Rialto
    ///
    /// Prints the string [text] plus the string represention of [details] (if present).
    ///
    /// Output goes to the console, the browser's alert box, and the log element in the HTML.
    static void error(String text, [dynamic details = null]) {

        String s = "Error: $text";

        if (!s.endsWith("\n")) {
            s += "\n";
        }

        if (details != null) {
            s += 'Details: $details\n';
        }

        window.console.log(s);

        window.alert(s);

        var e = querySelector("#logDialog_body");
        if (e != null) {
            e.text += s + "\n";
        }
    }

    /// Logging function for all of Rialto
    ///
    /// Prints the string representation of [obj] to the console and the log element in the HTML.
    static void log(dynamic obj) {
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
}
