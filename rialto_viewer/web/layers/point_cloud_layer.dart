// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class PointCloudLayer extends Layer with VisibilityControl, ColorizerControl {
    var _provider;
    int numPoints;
    List<String> dimensions;

    ColorizerData _colorizerData = new ColorizerData("Spectral", "Z");

    bool _visible = true;

    PointCloudLayer(String name, Map map)
            : super("pointcloud", name, map) {
        _requireUrl();
    }

    @override
    Future load() {
        Completer c = new Completer();

        _hub.cesium.createTileProviderAsync(
                urlString,
                _colorizerData.ramp,
                _colorizerData.dimension,
                visible).then((provider) {
            _provider = provider;

            numPoints = _hub.cesium.getNumPointsFromProvider(_provider);

            var list = _hub.cesium.getTileBboxFromProvider(_provider);

            var xStats = _hub.cesium.getStatsFromProvider(_provider, "X");
            var yStats = _hub.cesium.getStatsFromProvider(_provider, "Y");
            var zStats = _hub.cesium.getStatsFromProvider(_provider, "Z");

            _bbox = new CartographicBbox.fromValues(xStats[0], yStats[0], zStats[0], xStats[2], yStats[2], zStats[2]);

            dimensions = _hub.cesium.getDimensionNamesFromProvider(_provider);

            c.complete();
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

    ColorizerData get colorizerData => _colorizerData;

    // note this doesn't run the colorizer, you need to do that manually
    set colorizerData(ColorizerData d) {
        _colorizerData = d;
    }

    Future colorizeAsync() {
        return new Future(() {
            _hub.cesium.unloadTileProvider(_provider);
            load();
        });
    }
}
