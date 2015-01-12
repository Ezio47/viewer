// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class AnnotationShape extends Shape {

    Vector3 _point1;
    Vector3 _point2;

    AnnotationShape(Vector3 point1, Vector3 point2) : super() {
        _point1 = point1;
        _point2 = point2;

        assert(_point1.x <= _point2.x);
        assert(_point1.y <= _point2.y);
        assert(_point1.z == _point2.z);
        isSelectable = true;

        _primitive = _createCesiumObject();
    }

    @override
    dynamic _createCesiumObject() {
        return _hub.cesium.createRectangle(_point1, _point2, 0.0, 1.0, 1.0);
    }
}
