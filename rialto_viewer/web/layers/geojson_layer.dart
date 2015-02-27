// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class GeoJsonLayer extends UrlLayer {
    dynamic dataSource;

    GeoJsonLayer(String name, Map map)
            : super("geojson", name, map);

    @override
    Future<bool> load() {
        Completer c = new Completer();

        dataSource = _hub.cesium.addGeoJson(_url.toString());

        // TODO: set visibility
        // TODO: set bbox

        c.complete(true);

        return c.future;
    }
}
