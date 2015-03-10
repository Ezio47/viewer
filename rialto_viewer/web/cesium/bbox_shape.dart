// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class BboxShape {
    Hub _hub;

    var primitive;

    Cartographic3 _point1, _point2;

    BboxShape(this._point1, this._point2) {
        _hub = Hub.root;
        primitive = _createCesiumObject();
    }

    bool get isVisible => _hub.cesium.isPrimitiveVisible(primitive);

    set isVisible(bool value) => _hub.cesium.setPrimitiveVisible(primitive, value);

    dynamic _createCesiumObject() {
        return _hub.cesium.createBbox(_point1, _point2);
    }

    void remove() {
        _hub.cesium.remove(primitive);
    }
}
