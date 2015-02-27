// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

abstract class ImageryLayer extends Layer {

    dynamic _provider;
    Uri _url;
    List<num> _rect;

    ImageryLayer(String name, Map map)
            : super(name, map),
              _url = YamlUtils.getRequiredSettingAsUri(map, "url"),
              _rect = YamlUtils.getOptionalSettingAsList4(map, "rect"); // w, s, e, n
}


class SingleImageryLayer extends ImageryLayer {

    SingleImageryLayer(String name, Map map)
            : super(name, map);

    @override
    Future<bool> load() {
        String url = _url.toString();
        _provider = _hub.cesium.addSingleTileImageryProvider(url, _rect, _proxy);
        return new Future(() {});
    }
}


class WmsImageryLayer extends ImageryLayer {
    String _layers;

    WmsImageryLayer(String name, Map map)
            : super(name, map),
            _layers = YamlUtils.getRequiredSettingAsString(map, "layers");

    @override
    Future<bool> load() {
        String url = _url.toString();
        _provider = _hub.cesium.addWebMapServiceImageryProvider(url, _layers, _rect, _proxy);
        return new Future(() {});
    }
}


class WtmsImageryLayer extends ImageryLayer {
    String _layers;
    int _maximumLevel;

    WtmsImageryLayer(String name, Map map)
            : super(name, map),
            _maximumLevel = YamlUtils.getOptionalSettingAsInt(map, "maximumLevel", 18);

    @override
    Future<bool> load() {
        String url = _url.toString();
        _provider = _hub.cesium.addTileMapServiceImageryProvider(url, _rect, _maximumLevel, _proxy);
        return new Future(() {});
    }
}
