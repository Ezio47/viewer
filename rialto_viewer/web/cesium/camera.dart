// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class Camera {
    Hub _hub;

    Camera() {
        _hub = Hub.root;
    }

    Future zoomTo(Cartographic3 eyePosition, Cartographic3 targetPosition, Cartesian3 upDirection, double fov) {

        _hub.cesium.lookAt(eyePosition, targetPosition, upDirection, fov);

        return new Future.value();
    }

    Future zoomToLayer(Layer layer) {
        if (layer == null) {
            layer = _hub.layerManager.layers.last;
        }

        if (layer == null || layer.bbox == null) {
            return new Future.value();
        }

        // _eyePosition = data.eye;
        // _targetPosition = data.target;
        // _upDirection = data.up;
        // _cameraFov = data.fov;

        var bbox = layer.bbox;
        double west = bbox.west;
        double south = bbox.south;
        double east = bbox.east;
        double north = bbox.north;

        double centerLon = east + (west - east) / 2.0;
        double centerLat = south + (north - south) / 2.0;

        var targetPosition = new Cartographic3(centerLon, centerLat, 0.0);

        var h = max(west - east, north - south) * 1000.0;
        var eyePosition = new Cartographic3(centerLon, centerLat, h);


        final Cartesian3 upDirection = new Cartesian3(0.0, 0.0, 1.0);
        final double fov = 60.0;

        _hub.cesium.lookAt(eyePosition, targetPosition, upDirection, fov);

        return new Future.value();
    }

    Future zoomToWorld() {
        _hub.cesium.goHome();
        return new Future(() {});
    }

}
