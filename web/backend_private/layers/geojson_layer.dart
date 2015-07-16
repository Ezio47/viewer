// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend.private;

class GeoJsonLayer extends Layer {
  dynamic _dataSource;

  GeoJsonLayer(RialtoBackend backend, String name, Map map) : super(backend, "geojson", name, map) {
    requireUrl();
  }

  @override
  Future load() {
    Completer c = new Completer();

    backend.cesium.addGeoJsonDataSource(name, urlString).then((ds) {
      _dataSource = ds;

      c.complete();
    });

    return c.future;
  }

  @override
  Future unload() {
    return new Future(() {
      backend.cesium.removeDataSource(_dataSource);
    });
  }
}
