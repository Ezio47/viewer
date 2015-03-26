// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

/// Holds all the layers loaded into the viewer.
///
/// All the layers are managed here, held in a list of [Layer] objects. Layers are stored in the
/// order the appeared in th config file (or the order in which they were added).
///
/// Don't access the list directly except for read access: use the provided add, remove, etc functions.
///
/// The [LayerManager] is owned by the [Rialto] and treated as a singleton.
class LayerManager {
    Rialto _hub;
    List<Layer> layers = new List<Layer>();
    Map<String, Layer> _layerMap = new Map<String, Layer>();
    bool _hasBaseImagery = false;

    /// Create the (singleton) manager
    LayerManager() : _hub = Rialto.root;

    /// Colorize all (point cloud) layers
    Future colorizeLayers(ColorizerData data) {
        var futures = new List<Future>();

        for (var layer in _hub.layerManager.layers) {
            if (layer is PointCloudLayer) {
                (layer as ColorizerControl).colorizerData = data;
                Future f = layer.colorizeAsync();
                futures.add(f);
            }
        }

        var wait = Future.wait(futures);

        return wait;
    }

    /// Add a new layer and asynchronously load it's data into viewer
    Future<Layer> addLayer(LayerData data) {
        final name = data.name;

        var c = new Completer<Layer>();

        if (_layerMap.containsKey(name)) {
            Rialto.error("Layer $name already loaded.");
            c.complete(null);
            return c.future;
        }

        Layer layer = _createLayer(name, data.options);
        if (layer == null) {
            Rialto.error("Unable to load layer $name.");
            c.complete(null);
            return c.future;
        }

        layer.load().then((_) {
            layers.add(layer);
            _layerMap[layer.name] = layer;

            _hub.events.AddLayerCompleted.fire(layer);

            c.complete(layer);
        });

        return c.future;
    }

    /// Given a layer name, return the [Layer] object
    ///
    /// Returns null if no such layer present.
    Layer lookupLayer(String name) {
        return _layerMap[name];
    }

    /// Removes a layer from the manager and triggers a viewer update.
    ///
    /// [layer] must be a valid [Layer] in the list.
    Future removeLayer(Layer layer) {
        if (layer == null || !layers.contains(layer)) {
            throw new ArgumentError("unable to remove layer");
        }

        _layerMap.remove(layer.name);
        layers.remove(layer);

        layer.unload();

        _hub.events.RemoveLayerCompleted.fire(layer);

        return new Future.value();
    }

    /// Removes all layers from the manager
    ///
    /// Invokes [removeLayer] for each layer in the list.
    Future removeAllLayers() {
        var items = layers.toList();
        items.forEach((layer) => _hub.commands.removeLayer(layer));

        layers.clear();
        _layerMap.clear();

        _hub.events.RemoveAllLayersCompleted.fire0();

        return new Future.value();
    }

    Layer _createLayer(String name, Map map) {

        assert(map.containsKey("type"));

        String type = map["type"];

        Layer layer = null;
        switch (type) {

            case "bing_base_imagery":
                layer = new BingBaseImageryLayer(name, map);
                _hasBaseImagery = true;
                break;

            case "arcgis_base_imagery":
                layer = new ArcGisBaseImageryLayer(name, map);
                _hasBaseImagery = true;
                break;

            case "osm_base_imagery":
                layer = new OsmBaseImageryLayer(name, map);
                _hasBaseImagery = true;
                break;

            case "ellipsoid_base_terrain":
                layer = new EllipsoidBaseTerrainLayer(name, map);
                break;

            case "arcgis_base_terrain":
                layer = new ArcGisBaseTerrainLayer(name, map);
                break;

            case "cesium_small_base_terrain":
                layer = new CesiumSmallBaseTerrainLayer(name, map);
                break;

            case "cesium_stk_base_terrain":
                layer = new CesiumStkBaseTerrainLayer(name, map);
                break;

            case "vrtheworld_base_terrain":
                layer = new VrTheWorldBaseTerrainLayer(name, map);
                break;

            case "wms_imagery":
                layer = new WmsImageryLayer(name, map);
                break;

            case "tms_imagery":
                layer = new TmsImageryLayer(name, map);
                break;

            case "single_imagery":
                if (!_hasBaseImagery) {
                    // TODO: under what conditions is this really a problem?
                    throw new ArgumentError("single_imagery requires a base imagery layer");
                }
                layer = new SingleImageryLayer(name, map);
                break;

            case "terrain":
                layer = new TerrainLayer(name, map);
                break;

            case "geojson":
                layer = new GeoJsonLayer(name, map);
                break;

            case "pointcloud":
                layer = new PointCloudLayer(name, map);
                break;

            default:
                Rialto.error("Unrecognized layer type in configuration file", "Layer type: $type");
                return null;
        }

        return layer;
    }
}
