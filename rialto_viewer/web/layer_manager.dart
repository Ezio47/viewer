// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class LayerManager {
    Hub _hub;
    Map<String, Layer> layers = new Map<String, Layer>();
    CartographicBbox bbox = new CartographicBbox.empty();

    LayerManager() {
        _hub = Hub.root;

        _hub.eventRegistry.AddLayer.subscribe(_handleAddLayer);
        _hub.eventRegistry.RemoveLayer.subscribe(_handleRemoveLayer);
    }

    void _handleAddLayer(LayerData data) {
        final name = data.name;

        assert(!layers.containsKey(name));

        Layer layer = LayerManager._createLayer(name, data.map);

        layers[layer.name] = layer;

        bbox.unionWith(layer.bbox);
        _hub.eventRegistry.LayersBboxChanged.fire(bbox);

        layer.load().then((_) {
            bbox.unionWith(layer.bbox);
            _hub.eventRegistry.LayersBboxChanged.fire(bbox);
            _hub.eventRegistry.AddLayerCompleted.fire(name);
        });
    }

    void _handleRemoveLayer(String name) {
        assert(layers.containsKey(name));
        Layer layer = layers[name];
        assert(layer != null);

        layers.remove(layer.name);

        bbox = new CartographicBbox.empty();
        for (var layer in layers.values) {
            bbox.unionWith(layer.bbox);
        }
        _hub.eventRegistry.LayersBboxChanged.fire(bbox);

        _hub.eventRegistry.RemoveLayerCompleted.fire(name);
    }


    // this function should do no heavywieght work, save that for load()
    static Layer _createLayer(String name, Map map) {

        assert(map.containsKey("type"));

        String type = map["type"];

        Layer layer = null;
        switch (type) {
            case "base_imagery":
                layer = new BaseImageryLayer(name, map);
                break;
            case "base_terrain":
                layer = new BaseTerrainLayer(name, map);
                break;
            case "imagery":
                layer = new ImageryLayer(name, map);
                break;
            case "terrain":
                layer = new TerrainLayer(name, map);
                break;
            case "vector":
                layer = new VectorLayer(name, map);
                break;
            case "pointcloud":
                layer = new PointCloudLayer(name, map);
                break;
            default:
                assert(false);
        }

        return layer;
    }
}
