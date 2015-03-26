// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class TerrainLayer extends Layer {

    dynamic _provider;

    TerrainLayer(RialtoBackend backend, String name, Map map)
            : super(backend, "terrain", name, map) {
        _requireUrl();
    }

    @override
    Future load() {
        var f = new Future(() {
            var options = {
                'url': urlString
            };
            _provider = _backend.cesium.setCesiumTerrainProvider(options);
        });
        return f;
    }

    @override
    Future unload() {
        var f = new Future(() {
            _backend.cesium.unsetTerrainProvider();
        });
        return f;
    }
}
