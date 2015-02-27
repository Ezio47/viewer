// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

abstract class ImageryLayer extends UrlLayer with VisibilityControl, AlphaControl, ColorCorrectionControl {

    dynamic _layer;
    Uri _url;
    List<num> _rectangle;

    bool _visible;
    double _alpha;
    double _brightness;
    double _contrast;
    double _hue;
    double _saturation;
    double _gamma;

    ImageryLayer(String type, String name, Map map)
            : super(type, name, map),
              _rectangle = YamlUtils.getOptionalSettingAsList4(map, "rectangle"); // w, s, e, n

    @override set visible(bool v) => _visible = _hub.cesium.setLayerVisible(_layer, v);
    @override bool get visible => _visible;

    @override set alpha(double d) => _alpha = _hub.cesium.setLayerAlpha(_layer, d);
    @override double get alpha => _alpha;

    @override set brightness(double d) => _brightness = _hub.cesium.setLayerBrightness(_layer, d);
    @override double get brightness => _brightness;

    @override set contrast(double d) => _contrast = _hub.cesium.setLayerContrast(_layer, d);
    @override double get contrast => _contrast;

    @override set hue(double d) => _hue = _hub.cesium.setLayerHue(_layer, d);
    @override double get hue => _hue;

    @override set saturation(double d) => _saturation = _hub.cesium.setLayerSaturation(_layer, d);
    @override double get saturation => _saturation;

    @override set gamma(double d) => _gamma = _hub.cesium.setLayerGamma(_layer, d);
    @override double get gamma => _gamma;
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
