// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class TerrainLayer extends UrlLayer {

    dynamic _provider;

    TerrainLayer(String name, Map map)
            : super("terrain", name, map);

    @override
    Future load() {
        var f = new Future(() {

            String url = _url.toString();
            _provider = _hub.cesium.setCesiumTerrainProvider(url);
        });
        return f;
    }
}
