// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class AxesShape extends Shape {
    Cartographic3 origin;
    Vector3 length;

    AxesShape(Cartographic3 this.origin, Vector3 this.length) : super("axes") {
        _primitive = _createCesiumObject();
    }

    @override
    dynamic _createCesiumObject() {
        return _hub.cesium.createAxes(origin, length);
    }
}
