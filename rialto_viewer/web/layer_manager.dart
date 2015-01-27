// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class LayerManager {
    Map<String, Layer> layers = new Map<String, Layer>();

    LayerManager();

    void createLayer(Map map) {
        assert(map.containsKey("name"));
        String name = map.remove("name");

        assert(!layers.containsKey(name));

        assert(map.containsKey("type"));
        assert(map.containsKey("server"));
        assert(map.containsKey("path"));

        String type = map.remove("type");
        String server = map.remove("server");
        String path = map.remove("path");

        Layer layer = null;
        switch (type) {
            case "base_imagery":
                layer = new BaseImageryLayer(name,  server,  path);
                break;
            case "base_terrain":
                layer = new BaseTerrainLayer(name,  server,  path);
                break;
            case "imagery":
                layer = new ImageryLayer(name,  server,  path);
                break;
            case "terrain":
                layer = new TerrainLayer(name,  server,  path);
                break;
            case "vector":
                layer = new VectorLayer(name,  server,  path);
                break;
            case "pointcloud":
                layer = new PointCloudLayer(name,  server,  path);
                break;
            default:
                assert(false);
        }

        // process any remaining keys
        for (String key in map.keys) {
            switch (key) {
                default:
                    assert(false);
            }
        }

        layers[name] = layer;
    }
}
