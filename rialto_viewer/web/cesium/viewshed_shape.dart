// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class ViewshedShape extends Shape {

    Cartographic3 _point1;
    double radius;

    ViewshedShape(Cartographic3 point1, Cartographic3 point2) : super("viewshed") {
        _point1 = point1;
        radius = point1._vector.distanceTo(point2._vector);

        isSelectable = true;

        _primitive = _createCesiumObject();
    }

    @override
    dynamic _createCesiumObject() {
        return _hub.cesium.createCircle(_point1, 10000.0, 0.0, 1.0, 0.0);
    }
}
