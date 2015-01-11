// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

// this serves as an interface to the JavaScript functions in CesiumBridge
class Cesium {
    var _viewer;

    Cesium(String elementName) {
        _viewer = new JsObject(context['CesiumBridge'], [elementName]);
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
        assert(false);
        return null;
    }

    dynamic createBbox(Vector3 point1, Vector3 point2) {
        assert(false);
        return null;
    }

    dynamic createLine(Vector3 point1, Vector3 point2) {
        assert(false);
        return null;
    }

    dynamic createCloud(int numPoints, Float32List points, Float32List colors) {
        assert(false);
        return null;
    }

}
