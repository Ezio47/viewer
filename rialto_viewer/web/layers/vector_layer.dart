// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class VectorLayer extends Layer {
    dynamic dataSource;

    VectorLayer(String name, Map map)
            : super(name, map) {
        log("New vector layer: $name .. $server .. $path");
    }

    @override
    Future<bool> load() {
        Completer c = new Completer();

        dataSource = _hub.cesium.addGeoJson(server + path);
        //dataSource = _hub.cesium.addGeoJson('http://localhost:12345/poly.json');
        //_hub.cesium.addGeoJson('http://localhost:12345/mpg.json');

        // TODO: set visibility
        // TODO: set bbox

        c.complete(true);

        return c.future;
    }

    @override
    void changeVisibility(bool v) {
        throw new UnimplementedError("vector layer visibility");
    }
}
