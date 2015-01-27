// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class LayerManager {
    Map<String, Layer> layers = new Map<String, Layer>();

    LayerManager();

    void createLayer(String name, Map map) {
        assert(!layers.containsKey(name));

        assert(map.containsKey("type"));

        String type = map["type"];

        Layer layer = null;
        switch (type) {
            case "base_imagery":
                layer = new BaseImageryLayer(name,  map);
                break;
            case "base_terrain":
                layer = new BaseTerrainLayer(name,  map);
                break;
            case "imagery":
                layer = new ImageryLayer(name,  map);
                break;
            case "terrain":
                layer = new TerrainLayer(name,  map);
                break;
            case "vector":
                layer = new VectorLayer(name,  map);
                break;
            case "pointcloud":
                layer = new PointCloudLayer(name,  map);
                break;
            default:
                assert(false);
        }

        layers[name] = layer;
    }
}
