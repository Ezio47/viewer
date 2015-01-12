// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class MeasurementShape extends Shape {
    Vector3 _point1;
    Vector3 _point2;

    MeasurementShape(Vector3 this._point1, Vector3 this._point2) : super() {
        isSelectable = true;
        _primitive = _createCesiumObject();
    }

    @override
    dynamic _createCesiumObject() {
        return _hub.cesium.createLine(_point1, _point2, 1.0, 1.0, 0.0);
    }
}
