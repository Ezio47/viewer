// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class LayerManager {
    Hub _hub;
    Map<String, Layer> layers = new Map<String, Layer>();
    CartographicBbox bbox = new CartographicBbox.empty();
    bool _hasBaseImagery = false;

    LayerManager() :
        _hub = Hub.root;

    Future doColorizeLayers(ColorizeLayersData data) {
        var futures = new List<Future>();

        for (var layer in layers.values) {
            if (layer is PointCloudLayer) {
                Future f = layer.colorizeAsync(data);
                futures.add(f);
            }
        }

        var wait = Future.wait(futures);

        return wait;
    }

    Future<Layer> doAddLayer(LayerData data) {
        final name = data.name;

        var c = new Completer<Layer>();

        if (layers.containsKey(name)) {
            Hub.error("Layer $name already loaded.");
            c.complete(null);
            return c.future;
        }

        Layer layer = _createLayer(name, data.map);
        if (layer == null) {
            Hub.error("Unable to load layer $name.");
            c.complete(null);
            return c.future;
        }

        layer.load().then((_) {
            layers[layer.name] = layer;

            bbox.unionWith(layer.bbox);
            _hub.events.LayersBboxChanged.fire(bbox);

            _hub.events.AddLayerCompleted.fire(layer);

            c.complete(layer);
        });

        return c.future;
    }

    Future doRemoveLayer(String name) {
        assert(layers.containsKey(name));
        Layer layer = layers[name];
        assert(layer != null);

        layers.remove(layer.name);

        bbox = new CartographicBbox.empty();
        for (var layer in layers.values) {
            bbox.unionWith(layer.bbox);
        }
        _hub.events.LayersBboxChanged.fire(bbox);

        _hub.events.RemoveLayerCompleted.fire(name);

        return new Future((){});
    }

    Future doRemoveAllLayers() {
        var items = layers.values.toList();
        items.forEach((layer) => _hub.commands.removeLayer(layer.name));
        _hub.events.RemoveAllLayersCompleted.fire0();

        return new Future((){});
    }

    // this function should do no heavywieght work, save that for load()
    Layer _createLayer(String name, Map map) {

        assert(map.containsKey("type"));

        String type = map["type"];

        Layer layer = null;
        switch (type) {
            case "base_imagery":
                layer = new BaseImageryLayer(name, map);
                _hasBaseImagery = true;
                break;
            case "base_terrain":
                layer = new BaseTerrainLayer(name, map);
                break;
            case "wms_imagery":
                layer = new WmsImageryLayer(name, map);
                break;
            case "wtms_imagery":
                layer = new WtmsImageryLayer(name, map);
                break;
            case "single_imagery":
                if (!_hasBaseImagery) {
                    // TODO: under what conditions is this really a problem?
                    throw new ArgumentError("single_imagery requires a base imager layer");
                }
                layer = new SingleImageryLayer(name, map);
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
                Hub.error("Unrecognized layer type in configuration file", info: {
                    "Layer type": type
                });
                return null;
        }

        return layer;
    }
}
