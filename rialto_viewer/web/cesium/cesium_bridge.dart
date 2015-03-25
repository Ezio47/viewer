// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// this serves as an interface to the JavaScript functions in CesiumBridge
class CesiumBridge {
    JsObject _bridge;


    //---------------------------------------------------------------------------------------------
    //
    // ctor
    //
    //---------------------------------------------------------------------------------------------

    CesiumBridge(String elementName) {
        _bridge = new JsObject(context['CesiumBridge'], [elementName]);

        _bridge.callMethod('createDrawHelper', [elementName]);

    }


    //---------------------------------------------------------------------------------------------
    //
    // annotations
    //
    //---------------------------------------------------------------------------------------------

    void drawMarker(Function callback) {
        _bridge.callMethod('drawMarker', [callback]);
    }

    void drawExtent(Function callback) {
        _bridge.callMethod('drawExtent', [callback]);
    }

    void drawCircle(Function callback) {
        _bridge.callMethod('drawCircle', [callback]);
    }

    void drawPolyline(Function callback) {
        _bridge.callMethod('drawPolyline', [callback]);
    }

    void drawPolygon(Function callback) {
        _bridge.callMethod('drawPolygon', [callback]);
    }

    //---------------------------------------------------------------------------------------------
    //
    // imagery providers
    //
    //---------------------------------------------------------------------------------------------

    dynamic addSingleTileImageryLayer(String url, List<num> rectList, String proxyUrl) {
        var rect = (rectList == null || rectList == []) ?
                null :
                _bridge.callMethod('newRectangleFromDegrees', [rectList[0], rectList[1], rectList[2], rectList[3]]);
        var proxy = (proxyUrl == null) ? null : _bridge.callMethod('createProxy', [proxyUrl]);
        var layer = _bridge.callMethod('addSingleTileImageryLayer', [url, rect, proxy]);
        return layer;
    }

    dynamic addWebMapServiceImageryLayer(String url, String layers, List<num> rectList, String proxyUrl) {
        var rect = (rectList == null || rectList == []) ?
                null :
                _bridge.callMethod('newRectangleFromDegrees', [rectList[0], rectList[1], rectList[2], rectList[3]]);
        var proxy = (proxyUrl == null) ? null : _bridge.callMethod('createProxy', [proxyUrl]);
        var layer = _bridge.callMethod('addWebMapServiceImageryLayer', [url, layers, rect, proxy]);
        return layer;
    }

    dynamic addTileMapServiceImageryLayer(String url, List<num> rectList, int maximumLevel, bool gdal2Tiles,
            String proxyUrl) {
        var rect = (rectList == null || rectList == []) ?
                null :
                _bridge.callMethod('newRectangleFromDegrees', [rectList[0], rectList[1], rectList[2], rectList[3]]);
        var proxy = (proxyUrl == null) ? null : _bridge.callMethod('createProxy', [proxyUrl]);
        var layer = _bridge.callMethod('addTileMapServiceImageryLayer', [url, rect, maximumLevel, gdal2Tiles, proxy]);
        return layer;
    }


    //---------------------------------------------------------------------------------------------
    //
    // imagery layer support
    //
    //---------------------------------------------------------------------------------------------

    void setLayerVisible(dynamic layer, bool v) => _bridge.callMethod('setLayerVisible', [layer, v]);

    void setLayerAlpha(dynamic layer, double d) => _bridge.callMethod('setLayerAlpha', [layer, d]);

    void setLayerBrightness(dynamic layer, double d) => _bridge.callMethod('setLayerBrightness', [layer, d]);

    void setLayerContrast(dynamic layer, double d) => _bridge.callMethod('setLayerContrast', [layer, d]);

    void setLayerHue(dynamic layer, double d) => _bridge.callMethod('setLayerHue', [layer, d]);

    void setLayerSaturation(dynamic layer, double d) => _bridge.callMethod('setLayerSaturation', [layer, d]);

    void setLayerGamma(dynamic layer, double d) => _bridge.callMethod('setLayerGamma', [layer, d]);


    //---------------------------------------------------------------------------------------------
    //
    // base imagery providers
    //
    //---------------------------------------------------------------------------------------------

    // returns a layer
    dynamic addBingBaseImageryLayer(Map<String, String> options) {
        return _bridge.callMethod('setBingBaseImageryProvider', [new JsObject.jsify(options)]);
    }

    // returns a layer
    dynamic addArcGisBaseImageryLayer(Map<String, String> options) {
        return _bridge.callMethod('setArcGisBaseImageryProvider', [new JsObject.jsify(options)]);
    }

    // returns a layer
    dynamic addOsmBaseImageryLayer(Map<String, String> options) {

        return _bridge.callMethod('setOsmBaseImageryProvider', [new JsObject.jsify(options)]);
    }

    void removeImageryLayer(dynamic layer) {
        _bridge.callMethod('removeImageryLayer', [layer]);
    }


    //---------------------------------------------------------------------------------------------
    //
    // terrain providers
    //
    //---------------------------------------------------------------------------------------------

    // returns a terrain provider
    dynamic setCesiumTerrainProvider(Map<String, String> options) {
        return _bridge.callMethod('setCesiumTerrainProvider', [new JsObject.jsify(options)]);
    }

    // returns a terrain provider
    dynamic setEllipsoidBaseTerrainProvider(Map<String, String> options) {
        return _bridge.callMethod('setEllipsoidBaseTerrainProvider', [new JsObject.jsify(options)]);
    }

    // returns a terrain provider
    dynamic setVrTheWorldBaseTerrainProvider(Map<String, String> options) {
        return _bridge.callMethod('setVrTheWorldBaseTerrainProvider', [new JsObject.jsify(options)]);
    }

    // returns a terrain provider
    dynamic setCesiumBaseTerrainProvider(Map<String, String> options) {
        return _bridge.callMethod('setCesiumBaseTerrainProvider', [new JsObject.jsify(options)]);
    }

    // returns a terrain provider
    dynamic setArcGisBaseTerrainProvider(options) {
        return _bridge.callMethod('setArcGisBaseTerrainProvider', [new JsObject.jsify(options)]);
    }

    void unsetTerrainProvider() {
        _bridge.callMethod('unsetTerrainProvider', []);
    }

    void unsetBaseTerrainProvider() {
        _bridge.callMethod('unsetBaseTerrainProvider', []);
    }


    //---------------------------------------------------------------------------------------------
    //
    // point cloud support
    //
    //--------------------------------------------------------------------------------------------

    Future<dynamic> createTileProviderAsync(String url, String colorizeRamp, String colorizeDimension, bool visible) {
        var c = new Completer<dynamic>();

        var cb = (obj) {
            c.complete(obj);
        };

        _bridge.callMethod('createTileProviderAsync', [url, colorizeRamp, colorizeDimension, visible, cb]);

        return c.future;
    }

    void unloadTileProvider(var provider) {
        return _bridge.callMethod('unloadTileProvider', [provider]);
    }

    dynamic getDimensionNamesFromProvider(var provider) {
        return _bridge.callMethod('getDimensionNamesFromProvider', [provider]);
    }

    dynamic getColorRampNames() {
        return _bridge.callMethod('getColorRampNames', []);
    }

    dynamic getNumPointsFromProvider(var provider) {
        return _bridge.callMethod('getNumPointsFromProvider', [provider]);
    }

    dynamic getTileBboxFromProvider(var provider) {
        return _bridge.callMethod('getTileBboxFromProvider', [provider]);
    }

    dynamic getStatsFromProvider(var provider, var dimName) {
        return _bridge.callMethod('getStatsFromProvider', [provider, dimName]);
    }


    //---------------------------------------------------------------------------------------------
    //
    // geojson support
    //
    //--------------------------------------------------------------------------------------------

    void removeDataSource(var dataSource) {
        _bridge.callMethod('removeDataSource', [dataSource]);
    }

    void setDataSourceVisible(var dataSource, bool v) {
        _bridge.callMethod('setDataSourceVisible', [dataSource, v]);
    }

    Future<dynamic> addGeoJsonDataSource(String name, String url) {
        var c = new Completer<dynamic>();

        var cb = (obj) {
            c.complete(obj);
        };

        _bridge.callMethod('addGeoJsonDataSource', [name, url, cb]);

        return c.future;
    }


    //---------------------------------------------------------------------------------------------
    //
    // home & view mode support
    //
    //--------------------------------------------------------------------------------------------

    void setViewMode(int m) {
        _bridge.callMethod('setViewMode', [m]);
    }

    void goHome() {
        _bridge.callMethod('goHome');
    }

    // eye & taregt inputs in cartographic lat/lon, height in kilometers
    // up vector is cartsian
    void lookAt(Cartographic3 eye, Cartographic3 target, Cartesian3 up, double fovDegrees) {
        _bridge.callMethod(
                'lookAtCartographic',
                [
                        eye.longitude,
                        eye.latitude,
                        eye.height * 1000.0,
                        target.longitude,
                        target.latitude,
                        target.height * 1000.0,
                        up.x,
                        up.y,
                        up.z,
                        fovDegrees]);
    }


    //---------------------------------------------------------------------------------------------
    //
    // primitive support
    //
    //--------------------------------------------------------------------------------------------

    bool isPrimitiveVisible(var primitive) {
        return _bridge.callMethod('isPrimitiveVisible', [primitive]);
    }

    void setPrimitiveVisible(var primitive, bool value) {
        _bridge.callMethod('setPrimitiveVisible', [primitive, value]);
    }

    dynamic createBbox(Cartographic3 point1, Cartographic3 point2) {
        assert(_isValidLatLon(point1));
        assert(_isValidLatLon(point2));
        var prim = _bridge.callMethod(
                'createBbox',
                [point1.longitude, point1.latitude, point1.height, point2.longitude, point2.latitude, point2.height]);
        return prim;
    }

    void remove(dynamic primitive) {
        _bridge.callMethod('removePrimitive', [primitive]);
    }


    //---------------------------------------------------------------------------------------------
    //
    // mouse support
    //
    //--------------------------------------------------------------------------------------------

    void onMouseMove(f) => _bridge.callMethod('onMouseMove', [f]);
    void onMouseDown(f) => _bridge.callMethod('onMouseDown', [f]);
    void onMouseUp(f) => _bridge.callMethod('onMouseUp', [f]);
    void onMouseWheel(f) => _bridge.callMethod('onMouseWheel', [f]);

    Cartographic3 getMouseCoordinates(double windowX, double windowY) {
        var xyz = _bridge.callMethod('getMouseCoords', [windowX, windowY]);
        if (xyz == null) return null;
        double x = xyz[0].toDouble();
        double y = xyz[1].toDouble();
        double z = xyz[2].toDouble();
        return new Cartographic3(x, y, z);
    }


    //---------------------------------------------------------------------------------------------
    //
    // utils
    //
    //--------------------------------------------------------------------------------------------

    double cartographicDistance(double lon1, double lat1, double lon2, double lat2) {
        return _bridge.callMethod('cartographicDistance', [lon1, lat1, lon2, lat2]);
    }

    static bool _isValidLatLon(Cartographic3 v) {
        final lonOk = (v.longitude >= -180.0 && v.longitude <= 180.0);
        if (!lonOk) return false;

        final latOk = (v.latitude >= -90.0 && v.latitude <= 90.0);
        if (!latOk) return false;

        const MAX_HEIGHT = 100000;
        final hOk = (v.height >= -MAX_HEIGHT && v.height <= MAX_HEIGHT);
        if (!hOk) return false;

        return true;
    }
}
