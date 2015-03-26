// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

/// Entry point to execute a Rialto viewer public function/operation
///
/// The [Rialto] singleton contains exactly one [Commands] object. External clients invoke
/// viewer operations by calling one of the functions in this class.
class Commands {
    Rialto _rialto;

    /// Create the commands object
    Commands() : _rialto = Rialto.root;

    /// Allow user to draw a circle to be used for a viewshed analysis
    void createViewshedCircle() {
        _rialto.cesium.drawCircle(
                (longitude, latitude, height, radius) => _rialto.viewshedCircles.add([longitude, latitude, height, radius]));
    }

    /// Run the viewshed analysis for each viewshed circle
    void computeViewshed() {
        for (var v in _rialto.viewshedCircles) {
            double obsLon = v[0];
            double obsLat = v[1];
            //double obsHeight = v[2];
            var radius = v[3];

            Viewshedder.callWps(obsLon, obsLat, radius);
        }
    }

    /// Allow user to draw a polyline and compute the linear length
    ///
    /// stub for future work
    void computeLinearMeasurement() {
        _rialto.cesium.drawPolyline((positions) {
            Rialto.log("Length of ...");// + positions);
            var dist = _rialto.computeLength(positions);
            var mi = dist / 1609.34;
            window.alert("Distance: ${dist.toStringAsFixed(1)} meters (${mi.toStringAsFixed(1)} miles)");
        });
    }

    /// Allow user to draw a polygone and compute the area
    ///
    /// stub for future work
    void computeAreaMeasurement() {
        _rialto.cesium.drawPolygon((positions) {
            Rialto.log("Area of ...");// + positions);
            var area = _rialto.computeArea(positions);
            window.alert("Area: ${area.toStringAsFixed(1)} m^2");
        });
    }

    /// Allow the user to add a "marker" to the viewer.
    ///
    /// stub for future work
    void dropPin() {
        _rialto.cesium.drawMarker((position) {
            Rialto.log("Pin...");// + position);
        });
    }

    /// Allow the user to draw a bounding box
    ///
    /// stub for future work
    void drawExtent() {
        _rialto.cesium.drawExtent((n, s, e, w) {
            Rialto.log("Extent: " + n.toString() + " " + s.toString() + " " + e.toString() + " " + w.toString());
        });
    }

    /// Asynchronously adds a new layer to the viewer
    ///
    /// Returns a Future with the new [Layer] object.
    Future<Layer> addLayer(LayerData data) {
        return _rialto.layerManager.addLayer(data);
    }

    /// Asynchronously colorizes all the (point cloud) layers
    ///
    /// Returns an empty future when done.
    Future colorizeLayers(ColorizerData data) {
        return _rialto.layerManager.colorizeLayers(data);
    }

    /// Asynchronously removes [layer] from the viewer
    ///
    /// Returns an empty future when done.
    Future removeLayer(Layer layer) {
        return _rialto.layerManager.removeLayer(layer);
    }

    /// Asynchronously removes all layers from the viewer
    ///
    /// Returns an empty future when done.
    Future removeAllLayers() {
        return _rialto.layerManager.removeAllLayers();
    }

    /// Asynchronously reads in and execute a configuration script at the URL
    ///
    /// All current layers will be removed first.
    ///
    /// Returns a list with the results of each command.
    Future<List<dynamic>> loadScriptFromUrl(Uri url) {
        var s = new ConfigScript();
        var f = s.loadFromUrl(url);
        return f;
    }

    /// Asynchronously reads in and executes a configuration script in the string [yaml]
    ///
    /// All current layers will be removed first.
    ///
    /// Returns a list with the results of each command.
    Future<List<dynamic>> loadScriptFromStringAsync(String yaml) {
        var s = new ConfigScript();
        var f = s.loadFromString(yaml);
        return f;
    }

    /// Asynchronously executes an arbitrary WPS process
    Future<WpsJob> wpsExecuteProcess(WpsExecuteProcessData data) {
        return _rialto.wps.doWpsExecuteProcess(
                data,
                successHandler: data.successHandler,
                errorHandler: data.errorHandler,
                timeoutHandler: data.timeoutHandler);
    }

    /// Asynchronously requests description of a WPS function
    ///
    /// Returns the response document.
    Future<OgcDocument> wpsDescribeProcess(String processName) {
        return _rialto.wps.doWpsDescribeProcess(processName);
    }

    /// Asynchronously requests an OGC capabilities document.
    ///
    /// Returns the response document.
    Future owsGetCapabilities() {
        return _rialto.wps.doOwsGetCapabilities();
    }

    /// Zooms to the given point
    ///
    /// Returns an empty future when done.
    Future zoomTo(Cartographic3 eyePosition, Cartographic3 targetPosition, Cartesian3 upDirection, double fov) {
        return _rialto.zoomTo(eyePosition, targetPosition, upDirection, fov);
    }

    /// Zooms to the given layer.
    ///
    /// If [layer] is null, zooms to the last layer in the [LayerManager].
    ///
    /// Returns an empty future when done.
    Future zoomToLayer(Layer layer) {
        return _rialto.zoomToLayer(layer);
    }

    /// Zooms out to show the whole globe
    ///
    /// Returns an empty future when done.
    Future zoomToWorld() {
        return _rialto.zoomToWorld();
    }

    /// Sets the view mode to 2D, 2.5D, or 3D
    ///
    /// Returns an empty future when done.
    Future setViewMode(ViewModeData mode) {
        _rialto.cesium.setViewMode(mode.mode.index);
        return new Future.value();
    }
}

class LayerData {
    String name;
    Map options;
    LayerData(String this.name, Map this.options);
}

class WpsExecuteProcessData {
    final List<Object> parameters;
    final WpsJobResultHandler successHandler;
    final WpsJobResultHandler errorHandler;
    final WpsJobResultHandler timeoutHandler;

    WpsExecuteProcessData(List<Object> this.parameters, {WpsJobResultHandler successHandler: null,
            WpsJobResultHandler errorHandler: null, WpsJobResultHandler timeoutHandler: null})
            : this.successHandler = successHandler,
              this.errorHandler = errorHandler,
              this.timeoutHandler = timeoutHandler;
}

class ColorizerData {
    String ramp;
    String dimension;
    ColorizerData(String this.ramp, String this.dimension);
}

enum ViewModeCode {
    mode2D, mode25D, mode3D
}

class ViewModeData {
    final ViewModeCode mode;

    ViewModeData(ViewModeCode this.mode);

    static Map name = {
        ViewModeCode.mode2D: "2D",
        ViewModeCode.mode25D: "2.5D",
        ViewModeCode.mode3D: "3D"
    };
}
