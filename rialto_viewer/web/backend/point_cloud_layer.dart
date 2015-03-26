// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend;

// TODO: this class should live in rialto.backend.private

class PointCloudLayer extends Layer with VisibilityControl, ColorizerControl, BboxVisibilityControl {
    var _provider;
    int numPoints;
    List<String> dimensions;
    BboxShape _bboxShape;

    ColorizerData _colorizerData = new ColorizerData("Spectral", "Z");

    bool _visible = true;
    bool _bboxVisible = true;

    PointCloudLayer(RialtoBackend backend, String name, Map map)
            : super(backend, "pointcloud", name, map) {
        requireUrl();
    }

    @override
    Future load() {
        Completer c = new Completer();

        backend.cesium.createTileProviderAsync(
                urlString,
                _colorizerData.ramp,
                _colorizerData.dimension,
                visible).then((provider) {
            _provider = provider;

            numPoints = backend.cesium.getNumPointsFromProvider(_provider);

            var xStats = backend.cesium.getStatsFromProvider(_provider, "X");
            var yStats = backend.cesium.getStatsFromProvider(_provider, "Y");
            var zStats = backend.cesium.getStatsFromProvider(_provider, "Z");

            bbox = new CartographicBbox.fromValues(xStats[0], yStats[0], zStats[0], xStats[2], yStats[2], zStats[2]);

            dimensions = backend.cesium.getDimensionNamesFromProvider(_provider);

            if (_bboxShape != null) _bboxShape.remove();
            if (_bboxVisible && bbox != null && bbox.isValid) {
                _bboxShape = new BboxShape(backend, bbox.minimum, bbox.maximum);
            }

            c.complete();
        });

        return c.future;
    }

    @override
    Future unload() {
        return new Future(() {
            backend.cesium.unloadTileProvider(_provider);
        });
    }

    @override
    set visible(bool v) {
        _visible = v;
        backend.cesium.unloadTileProvider(_provider);
        load();
    }

    @override
    bool get visible => _visible;

    @override
    set bboxVisible(bool v) => _bboxShape.isVisible = v;

    @override
    bool get bboxVisible => _bboxShape.isVisible;

    ColorizerData get colorizerData => _colorizerData;

    // note this doesn't run the colorizer, you need to do that manually
    set colorizerData(ColorizerData d) {
        _colorizerData = d;
    }

    Future colorizeAsync() {
        return new Future(() {
            backend.cesium.unloadTileProvider(_provider);
            load();
        });
    }
}
