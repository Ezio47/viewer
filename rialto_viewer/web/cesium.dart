// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// this serves as an interface to the JavaScript functions in CesiumBridge
class Cesium {
    var _viewer;

    Cesium(String elementName) {
        _viewer = new JsObject(context['CesiumBridge'], [elementName]);
        _viewer.callMethod('createRect', [-120.0, 40.0, -116.0, 47.0]);
    }

    void setUpdateFunction(f) {
        _viewer.callMethod('setUpdater', [f]);
    }

    dynamic createFloat64Array(int len) {
        return new JsObject(context['Float64Array'], [len]);
    }

    dynamic createUint8Array(int len) {
        return new JsObject(context['Uint8Array'], [len]);
    }

    Vector3 get cameraEyePosition {
        assert(false);
        return null;
    }

    void set cameraEyePosition(Vector3 value) {
        assert(false);
    }

    Vector3 get cameraTargetPosition {
        assert(false);
        return null;
    }

    void set cameraTargetPosition(Vector3 value) {
        assert(false);
    }

    Vector3 get cameraUpDirection {
        assert(false);
        return null;
    }

    void set cameraUpDirection(Vector3 value) {
        assert(false);
    }

    Vector3 getMouseCoordinates() {
        assert(false);
        return null;
    }

    int getPickedShapeId() {
        assert(false);
        return null;
    }

    // the geometry construction functions return the primitive we made (as an opaque pointer)
    dynamic createRectangle(Vector3 point1, Vector3 point2) {
        assert(false);
        return null;
    }

    dynamic createAxes(double x, double y, double z) {
        var axes = _viewer.callMethod('createAxes', [x, y, z]);
        return axes;
    }

    dynamic createBbox(Vector3 point1, Vector3 point2) {
        var prim = _viewer.callMethod('createBbox', [0.0, 0.0, 0.0, 25.0, 25.0, 1000.0 * 1000.0]);
        return prim;
    }

    dynamic createLine(Vector3 point1, Vector3 point2) {
        var prim = _viewer.callMethod('createLine', [point1.x, point1.y, point1.z, point2.x, point2.y, point2.z]);
        return prim;
    }

    dynamic createCloud(int numPoints, Float32List points, Float32List colors) {
        assert(numPoints >= 0);
        assert(points.length == numPoints * 3);
        assert(colors.length == numPoints * 4);
        log(points[34]);

        var points2 = createFloat64Array(numPoints*3);
        var colors2 = createUint8Array(numPoints*4);
        for (int i=0; i<numPoints; i++) {
            points2[i*3+0] = points[i*3+0];
            points2[i*3+1] = points[i*3+1];
            points2[i*3+2] = points[i*3+2];
            colors2[i*4+0] = (colors[i*4+0] * 255.0).toInt();
            colors2[i*4+1] = (colors[i*4+1] * 255.0).toInt();
            colors2[i*4+2] = (colors[i*4+2] * 255.0).toInt();
            colors2[i*4+3] = (colors[i*4+3] * 255.0).toInt();
        }
        var prim = _viewer.callMethod('createCloud', [numPoints, points2, colors2]);
        return prim;
    }

}



/*
 *     var rect1 = csViewer.callMethod('createRect', [-92.0, 20.0, -86.0, 27.0]);
    var rect2 = csViewer.callMethod('createRect', [-120.0, 40.0, -116.0, 47.0]);
    //csViewer.callMethod('removePrimitive', [rect1]);

    var cnt = 1000;
    var ps = new JsObject(context['Float64Array'], [cnt * 3]);
    var cs = new JsObject(context['Uint8Array'], [cnt * 4]);

    var rnd = new Random();
    for (var i = 0; i < cnt; i++) {
        var rx = rnd.nextDouble() * 60.0 + 20.0;
        var ry = rnd.nextDouble() * 60.0 + 20.0;
        var rz = rnd.nextDouble() * 10000.0;
        ps[i * 3 + 0] = -rx;
        ps[i * 3 + 1] = ry;
        ps[i * 3 + 2] = rz;
        cs[i * 4 + 0] = 255;
        cs[i * 4 + 1] = 255;
        cs[i * 4 + 2] = 255;
        cs[i * 4 + 3] = 255;
    }


   */
