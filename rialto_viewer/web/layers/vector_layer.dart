// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class VectorLayer extends Layer {
    dynamic dataSource;

    VectorLayer(String name, Map map)
            : super(name, map) {
        log("New vector layer: $name .. $uri");
    }

    @override
    Future<bool> load() {
        Completer c = new Completer();

        dataSource = _hub.cesium.addGeoJson(uri.toString());

        // TODO: set visibility
        // TODO: set bbox

        c.complete(true);

        return c.future;
    }

    @override
    set visible(bool v) {
        if (v == _visible) return;

        if (v) {
            // make it visible
            _hub.cesium.addDataSource(dataSource);
        } else {
            // make it invisible
            _hub.cesium.removeDataSource(dataSource);
        }
        _visible = v;
    }
}
