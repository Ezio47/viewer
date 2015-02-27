// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

abstract class ImageryLayer extends UrlLayer {

    dynamic _layer;
    Uri _url;
    List<num> _rectangle;

    ImageryLayer(String type, String name, Map map)
            : super(type, name, map),
              _rectangle = YamlUtils.getOptionalSettingAsList4(map, "rectangle"); // w, s, e, n
}


class SingleImageryLayer extends ImageryLayer {

    SingleImageryLayer(String name, Map map)
            : super("single_imagery", name, map);

    @override
    Future<bool> load() {
        String url = _url.toString();
        String proxy = (_proxy == null) ? null : _proxy.toString();
        _layer = _hub.cesium.addSingleTileImageryProvider(url, _rectangle, proxy);
        return new Future(() {});
    }
}


class WmsImageryLayer extends ImageryLayer {
    String _layers;

    WmsImageryLayer(String name, Map map)
            : super("wms_imagery", name, map),
            _layers = YamlUtils.getRequiredSettingAsString(map, "layers");

    @override
    Future<bool> load() {
        String url = _url.toString();
        String proxy = (_proxy == null) ? null : _proxy.toString();
        _layer = _hub.cesium.addWebMapServiceImageryProvider(url, _layers, _rectangle, proxy);
        return new Future(() {});
    }
}


class WtmsImageryLayer extends ImageryLayer {
    String _layers;
    int _maximumLevel;

    WtmsImageryLayer(String name, Map map)
            : super("wtms_imagery", name, map),
            _maximumLevel = YamlUtils.getOptionalSettingAsInt(map, "maximumLevel", 18);

    @override
    Future<bool> load() {
        String url = _url.toString();
        String proxy = (_proxy == null) ? null : _proxy.toString();
        _layer = _hub.cesium.addTileMapServiceImageryProvider(url, _rectangle, _maximumLevel, proxy);
        return new Future(() {});
    }
}
