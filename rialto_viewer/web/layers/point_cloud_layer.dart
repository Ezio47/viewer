// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class PointCloudLayer extends Layer {
    PointCloud cloud;
    PointCloudColorizer _colorizer;

    static const int _pointsPerTile = 1024 * 10;

    Map tileObjects = new Map<String, PointCloudTile>();
    Map tilePrimitives = new Map<String, dynamic>();

    PointCloudLayer(String name, Map map)
            : super(name, map) {
        log("New tiled pointcloud layer: $name .. $server .. $path");
    }

    @override
    Future<bool> load() {
        Completer c = new Completer();

        cloud = new PointCloud(path, name);

        _hub.cesium.createTileProvider(server + path);

        assert(cloud != null);

        cloud.changeVisibility(isVisible);

        bbox = new CartographicBbox.copy(cloud.bbox);

        _colorizer = new PointCloudColorizer(cloud);

        c.complete(true);

        return c.future;
    }


    @override
    void changeVisibility(bool v) {
        cloud.changeVisibility(v);
        isVisible = v;
    }

    Future colorizeAsync(ColorizeLayersData data) {
        return new Future(() {
            _colorizer.ramp = data.ramp;
            _colorizer.dimension = data.dimension;
            _colorizer.colorize();
        });
    }
}
