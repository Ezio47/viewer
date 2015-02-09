// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class BboxShape extends Shape {
    Cartographic3 _point1, _point2;

    BboxShape(Cartographic3 this._point1, Cartographic3 this._point2) : super("bbox") {
        primitive = _createCesiumObject();
    }

    @override
    dynamic _createCesiumObject() {
        return _hub.cesium.createBbox(_point1, _point2);
    }
}
