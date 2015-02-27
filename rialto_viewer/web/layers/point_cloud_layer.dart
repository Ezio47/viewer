// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class PointCloudLayer extends UrlLayer with VisibilityControl {
    var _provider;
    int numPoints;
    String colorizeRamp = "Spectral";
    String colorizeDimension = "Z";

    bool _visible;

    PointCloudLayer(String name, Map map)
            : super("pointcloud", name, map);

    @override
    Future<bool> load() {
        Completer c = new Completer();

        _hub.cesium.createTileProviderAsync(url.toString(), colorizeRamp, colorizeDimension, visible).then((provider) {
            _provider = provider;

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
    set visible(bool v) {
        _visible = v;
        _hub.cesium.unloadTileProvider(_provider);
        load();
    }

    @override
    bool get visible => _visible;

    Future colorizeAsync(ColorizeLayersData data) {
        return new Future(() {
            _hub.cesium.unloadTileProvider(_provider);
            colorizeRamp = data.ramp;
            colorizeDimension = data.dimension;
            load();
        });
    }
}
