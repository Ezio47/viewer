// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend.private;


class TerrainLayer extends Layer {

    TerrainLayer(RialtoBackend backend, String name, Map map)
            : super(backend, "terrain", name, map) {
        requireUrl();
    }

    @override
    Future load() {
        var f = new Future(() {
            var options = {
                'url': urlString
            };
            backend.cesium.setCesiumTerrainProvider(options);
        });
        return f;
    }

    @override
    Future unload() {
        var f = new Future(() {
            backend.cesium.unsetTerrainProvider();
        });
        return f;
    }
}
