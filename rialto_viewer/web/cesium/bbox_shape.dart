// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class BboxShape {
    Hub _hub;

    var _primitive;
    bool _isVisible;

    Cartographic3 _point1, _point2;

    BboxShape(this._point1, this._point2) : _isVisible = true {
        _hub = Hub.root;
        _create();
    }

    bool get isVisible => _isVisible;

    set isVisible(bool value) {
        // TODO: why doesn't cesium.setPrimitiveVisible() work anymore?
        if (value && !_isVisible) {
            _create();
        } else if (!value && _isVisible) {
            remove();
        }
    }

    void _create() {
        _primitive = _hub.cesium.createBbox(_point1, _point2);
    }

    void remove() {
        if (_primitive != null) {
            _hub.cesium.remove(_primitive);
            _primitive = null;
        }
    }
}
