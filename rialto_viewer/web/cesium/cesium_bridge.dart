// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// this serves as an interface to the JavaScript functions in CesiumBridge
class CesiumBridge {
    JsObject _bridge;

    CesiumBridge(String elementName) {
        _bridge = new JsObject(context['CesiumBridge'], [elementName]);
    }

    Future<dynamic> createTileProviderAsync(String url) {
        var c = new Completer<dynamic>();

        var cb = (obj) { c.complete(obj); };

        _bridge.callMethod('createTileProviderAsync', [url, cb]);

        return c.future;
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

    dynamic addGeoJson(String url) {
        return _bridge.callMethod('addGeoJson', [url]);
    }

    void goHome() {
        _bridge.callMethod('goHome');
    }

    bool isPrimitiveVisible(var primitive) {
        return _bridge.callMethod('isPrimitiveVisible', [primitive]);
    }

    void setPrimitiveVisible(var primitive, bool value) {
        _bridge.callMethod('setPrimitiveVisible', [primitive, value]);
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

    void onMouseMove(f) => _bridge.callMethod('onMouseMove', [f]);
    void onMouseDown(f) => _bridge.callMethod('onMouseDown', [f]);
    void onMouseUp(f) => _bridge.callMethod('onMouseUp', [f]);
    void onMouseWheel(f) => _bridge.callMethod('onMouseWheel', [f]);

    void setUpdateFunction(f) {
        _bridge.callMethod('setUpdater', [f]);
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

    Cartographic3 getMouseCoordinates(int windowX, int windowY) {
        var xyz = _bridge.callMethod('getMouseCoords', [windowX, windowY]);
        if (xyz == null) return null;
        double x = xyz[0].toDouble();
        double y = xyz[1].toDouble();
        double z = xyz[2].toDouble();
        return new Cartographic3(x, y, z);
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

    dynamic createCloud(int numPoints, Float64List xArray, Float64List yArray, Float64List zArray,
            Uint8List rgbaArray) {
        assert(numPoints >= 0);
        assert(xArray.length == numPoints);
        assert(rgbaArray.length == numPoints * 4);


                //var prim = _bridge.callMethod('createCloud', [numPoints, xArray.buffer, yArray.buffer, zArray.buffer, rgbaArray.buffer]);
        var prim = _bridge.callMethod('createCloud', [numPoints, xArray, yArray, zArray, rgbaArray]);
        return prim;
    }

    void remove(dynamic primitive) {
        _bridge.callMethod('removePrimitive', [primitive]);
    }

    dynamic createLabel(String text, Vector3 point) {

        return _bridge.callMethod('createLabel', [text, point.x, point.y, point.z]);
    }
}
