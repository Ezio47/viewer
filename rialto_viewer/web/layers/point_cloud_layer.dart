// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class PointCloudLayer extends Layer {
    PointCloudColorizer _colorizer;
    var _provider;
    int numPoints;

    PointCloudLayer(String name, Map map)
            : super(name, map) {
        log("New pointcloud layer: $name .. $server .. $path");
    }

    @override
    Future<bool> load() {
        Completer c = new Completer();

        _hub.cesium.createTileProviderAsync(server + path).then((provider) {
            _provider = provider;

            _colorizer = new PointCloudColorizer(_provider);

            numPoints = _hub.cesium.getNumPointsFromProvider(_provider);

            var list = _hub.cesium.getTileBboxFromProvider(_provider);

            var xStats = _hub.cesium.getStatsFromProvider(_provider, "X");
            var yStats = _hub.cesium.getStatsFromProvider(_provider, "Y");
            var zStats = _hub.cesium.getStatsFromProvider(_provider, "Z");

            bbox = new CartographicBbox.fromValues(xStats[0], yStats[0], zStats[0], xStats[2], yStats[2], zStats[2]);

            c.complete(true);
        });

        return c.future;
    }


    @override
    void changeVisibility(bool v) {
        //      cloud.changeVisibility(v);
        isVisible = v;
    }

    Future colorizeAsync(ColorizeLayersData data) {
        return new Future(() {
//            _colorizer.ramp = data.ramp;
            //          _colorizer.dimension = data.dimension;
            //        _colorizer.colorize();
        });
    }
}
