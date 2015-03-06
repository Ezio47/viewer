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

        ///_bridge.callMethod('createDrawHelper', [elementName]);
    }


    //---------------------------------------------------------------------------------------------
    //
    // imagery providers
    //
    //---------------------------------------------------------------------------------------------

    dynamic addSingleTileImageryProvider(String url, List<num> rectList, String proxyUrl) {
        var rect = (rectList == null || rectList == []) ?
                null :
                _bridge.callMethod('newRectangleFromDegrees', [rectList[0], rectList[1], rectList[2], rectList[3]]);
        var proxy = (proxyUrl == null) ? null : _bridge.callMethod('createProxy', [proxyUrl]);
        var provider = _bridge.callMethod('newSingleTileImageryProvider', [url, rect, proxy]);
        var layer = _bridge.callMethod('addImageryProvider', [provider]);
        return layer;
    }

    dynamic addWebMapServiceImageryProvider(String url, String layers, List<num> rectList, String proxyUrl) {
        var rect = (rectList == null || rectList == []) ?
                null :
                _bridge.callMethod('newRectangleFromDegrees', [rectList[0], rectList[1], rectList[2], rectList[3]]);
        var proxy = (proxyUrl == null) ? null : _bridge.callMethod('createProxy', [proxyUrl]);
        var provider = _bridge.callMethod('newWebMapServiceImageryProvider', [url, layers, rect, proxy]);
        var layer = _bridge.callMethod('addImageryProvider', [provider]);
        return layer;
    }

    dynamic addTileMapServiceImageryProvider(String url, List<num> rectList, int maximumLevel, bool gdal2Tiles, String proxyUrl) {
        var rect = (rectList == null || rectList == []) ?
                null :
                _bridge.callMethod('newRectangleFromDegrees', [rectList[0], rectList[1], rectList[2], rectList[3]]);
        var proxy = (proxyUrl == null) ? null : _bridge.callMethod('createProxy', [proxyUrl]);
        var provider = _bridge.callMethod('newTileMapServiceImageryProvider', [url, rect, maximumLevel, gdal2Tiles, proxy]);
        var layer = _bridge.callMethod('addImageryProvider', [provider]);
        return layer;
    }


    //---------------------------------------------------------------------------------------------
    //
    // imagery layer support
    //
    //---------------------------------------------------------------------------------------------

    // returns a layer
    dynamic addImageryProvider(dynamic provider) {
        return _bridge.callMethod('addImageryProvider', [provider]);
    }

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
    dynamic setBingBaseImageryProvider(String apiKey, String style) {
        return _bridge.callMethod('setBingBaseImageryProvider', [apiKey, style]);
    }

    // returns a layer
    dynamic setArcGisBaseImageryProvider() {
        return _bridge.callMethod('setArcGisBaseImageryProvider', []);
    }

    // returns a layer
    dynamic setOsmBaseImageryProvider() {
        return _bridge.callMethod('setOsmBaseImageryProvider', []);
    }


    //---------------------------------------------------------------------------------------------
    //
    // terrain providers
    //
    //---------------------------------------------------------------------------------------------

    // returns a terrain provider
    dynamic setCesiumTerrainProvider(String url) {
        return _bridge.callMethod('setCesiumTerrainProvider', [url]);
    }

    // returns a terrain provider
    dynamic setEllipsoidBaseTerrainProvider() {
        return _bridge.callMethod('setEllipsoidBaseTerrainProvider', []);
    }

    // returns a terrain provider
    dynamic setVrTheWorldBaseTerrainProvider(String url) {
        return _bridge.callMethod('setVrTheWorldBaseTerrainProvider', [url]);
    }

    // returns a terrain provider
    dynamic setCesiumBaseTerrainProvider(String url, String credit) {
        return _bridge.callMethod('setCesiumBaseTerrainProvider', [url, credit]);
    }

    // returns a terrain provider
    dynamic setArcGisBaseTerrainProvider(apiKey) {
        return _bridge.callMethod('setArcGisBaseTerrainProvider', [apiKey]);
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

    void addDataSource(var dataSource) {
        _bridge.callMethod('addDataSource', [dataSource]);
    }

    void removeDataSource(var dataSource) {
        _bridge.callMethod('removeDataSource', [dataSource]);
    }

    void setDataSourceVisible(var dataSource, bool v) {
        _bridge.callMethod('setDataSourceVisible', [dataSource, v]);
    }

    Future<dynamic> addGeoJson(String name, String url) {
        var c = new Completer<dynamic>();

        var cb = (obj) {
            c.complete(obj);
        };

        _bridge.callMethod('addGeoJson', [name, url, cb]);

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

    // the geometry construction functions return the primitive we made (as an opaque pointer)
    dynamic createRectangle(Cartographic3 point1, Cartographic3 point2, double colorR, double colorG, double colorB) {
        assert(_isValidLatLon(point1));
        assert(_isValidLatLon(point2));
        return _bridge.callMethod(
                'createRectangle',
                [point1.longitude, point1.latitude, point2.longitude, point2.latitude, colorR, colorG, colorB]);
    }

    dynamic createCircle(Cartographic3 center, Cartographic3 point, double colorR, double colorG, double colorB) {
        assert(_isValidLatLon(center));
        assert(_isValidLatLon(point));
        return _bridge.callMethod(
                'createCircle',
                [center.longitude, center.latitude, point.longitude, point.latitude, colorR, colorG, colorB]);
    }

    dynamic createBbox(Cartographic3 point1, Cartographic3 point2) {
        assert(_isValidLatLon(point1));
        assert(_isValidLatLon(point2));
        var prim = _bridge.callMethod(
                'createBbox',
                [point1.longitude, point1.latitude, point1.height, point2.longitude, point2.latitude, point2.height]);
        return prim;
    }

    dynamic createLine(Cartographic3 point1, Cartographic3 point2, double colorR, double colorG, double colorB) {
        assert(_isValidLatLon(point1));
        assert(_isValidLatLon(point2));
        var prim = _bridge.callMethod(
                'createLine',
                [
                        point1.longitude,
                        point1.latitude,
                        point1.height,
                        point2.longitude,
                        point2.latitude,
                        point2.height,
                        colorR,
                        colorG,
                        colorB]);
        assert(prim != null);
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
