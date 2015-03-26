// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


/// Kludgy hack for attaching RGB-edged bounding boxes to a layer.
class BboxShape {
    RialtoBackend _backend;

    var _primitive;
    bool _isVisible;

    Cartographic3 _point1, _point2;

    BboxShape(RialtoBackend this._backend, this._point1, this._point2) : _isVisible = true {
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
        _primitive = _backend.cesium.createBbox(_point1, _point2);
    }

    void remove() {
        if (_primitive != null) {
            _backend.cesium.remove(_primitive);
            _primitive = null;
        }
    }
}
