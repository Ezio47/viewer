// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend.private;

/// Holds all the layers loaded into the viewer.
///
/// All the layers are managed here, held in a list of [Layer] objects. Layers are stored in the
/// order the appeared in th config file (or the order in which they were added).
///
/// Don't access the list directly except for read access: use the provided add, remove, etc functions.
///
/// The [LayerManager] is owned by the [Rialto] and treated as a singleton.
class LayerManager {
  RialtoBackend _backend;
  List<Layer> layers = new List<Layer>();
  Map<String, Layer> _layerMap = new Map<String, Layer>();
  bool _hasBaseImagery = false;

  /// Create the (singleton) manager
  LayerManager(RialtoBackend this._backend);

  Future<Layer> reloadLayer(Layer layer, Map newOptions) {
    var c = new Completer<Layer>();

    Map options = new Map();
    options.addAll(layer.options);
    options.addAll(newOptions);

    String name = layer.name;
    removeLayer(layer).then((_) {
      var l = addLayer(name, options);
      c.complete(l);
      return c.future;
    });

    return c.future;
  }

  /// Add a new layer and asynchronously load it's data into viewer
  Future<Layer> addLayer(String newName, Map newOptions) {
    final name = newName;

    var c = new Completer<Layer>();

    if (_layerMap.containsKey(name)) {
      RialtoBackend.error("Layer $name already loaded.");
      c.complete(null);
      return c.future;
    }

    Layer layer = _createLayer(name, newOptions);
    if (layer == null) {
      RialtoBackend.error("Unable to load layer $name.");
      c.complete(null);
      return c.future;
    }

    layer.load().then((_) {
      layers.add(layer);
      _layerMap[layer.name] = layer;

      _backend.events.AddLayerCompleted.fire(layer);

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

    var c = new Completer();
    layer.unload().then((_) {
      _backend.events.RemoveLayerCompleted.fire(layer);
      c.complete(new Future.value());
      return c.future;
    });

    return c.future;
  }

  /// Removes all layers from the manager
  ///
  /// Invokes [removeLayer] for each layer in the list.
  Future removeAllLayers() {
    var items = layers.toList();
    items.forEach((layer) => _backend.commands.removeLayer(layer));

    layers.clear();
    _layerMap.clear();

    _backend.events.RemoveAllLayersCompleted.fire0();

    return new Future.value();
  }

  Layer _createLayer(String name, Map map) {
    assert(map.containsKey("type"));

    String type = map["type"];

    Layer layer = null;
    switch (type) {
      case "bing_base_imagery":
        layer = new BingBaseImageryLayer(_backend, name, map);
        _hasBaseImagery = true;
        break;

      case "arcgis_base_imagery":
        layer = new ArcGisBaseImageryLayer(_backend, name, map);
        _hasBaseImagery = true;
        break;

      case "osm_base_imagery":
        layer = new OsmBaseImageryLayer(_backend, name, map);
        _hasBaseImagery = true;
        break;

      case "ellipsoid_base_terrain":
        layer = new EllipsoidBaseTerrainLayer(_backend, name, map);
        break;

      case "arcgis_base_terrain":
        layer = new ArcGisBaseTerrainLayer(_backend, name, map);
        break;

      case "cesium_small_base_terrain":
        layer = new CesiumSmallBaseTerrainLayer(_backend, name, map);
        break;

      case "cesium_stk_base_terrain":
        layer = new CesiumStkBaseTerrainLayer(_backend, name, map);
        break;

      case "vrtheworld_base_terrain":
        layer = new VrTheWorldBaseTerrainLayer(_backend, name, map);
        break;

      case "wms_imagery":
        layer = new WmsImageryLayer(_backend, name, map);
        break;

      case "tms_imagery":
        layer = new TmsImageryLayer(_backend, name, map);
        break;

      case "single_imagery":
        if (!_hasBaseImagery) {
          // TODO: under what conditions is this really a problem?
          throw new ArgumentError("single_imagery requires a base imagery layer");
        }
        layer = new SingleImageryLayer(_backend, name, map);
        break;

      case "terrain":
        layer = new TerrainLayer(_backend, name, map);
        break;

      case "geojson":
        layer = new GeoJsonLayer(_backend, name, map);
        break;

      case "pointcloud":
        layer = new PointCloudLayer(_backend, name, map);
        break;

      default:
        RialtoBackend.error("Unrecognized layer type in configuration file", "Layer type: $type");
        return null;
    }

    return layer;
  }
}
