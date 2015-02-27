// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class TerrainLayer extends Layer {

    dynamic _provider;
    Uri _url;

    TerrainLayer(String name, Map map)
            : super(name, map),
              _url = YamlUtils.getRequiredSettingAsUri(map, "url");

    @override
    Future<bool> load() {

        String url = _url.toString();
        _provider = _hub.cesium.setCesiumTerrainProvider(url);

        return new Future(() {});
    }
}
