// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class AnnotationShape extends Shape {

    Cartographic3 _point1;
    Cartographic3 _point2;

    AnnotationShape(Cartographic3 point1, Cartographic3 point2) : super("annotation") {
        _point1 = point1;
        _point2 = point2;

        assert(_point1.longitude <= _point2.longitude);
        assert(_point1.latitude <= _point2.latitude);
        assert(_point1.height == _point2.height);
        isSelectable = true;

        _primitive = _createCesiumObject();
    }

    @override
    dynamic _createCesiumObject() {
        return _hub.cesium.createRectangle(_point1, _point2, 0.0, 1.0, 1.0);
    }
}
