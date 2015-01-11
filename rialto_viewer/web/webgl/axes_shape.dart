// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class AxesShape extends Shape {
    double _xlen, _ylen, _zlen;

    AxesShape(double this._xlen, double this._ylen, double this._zlen) : super() {
    }

    @override
    void _createCesiumObject() {
        _hub.cesium.createAxes(_xlen, _ylen, _zlen);
    }
}
