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

    // rect is: w, s, e, n
    ImageryLayer(String type, String name, Map map)
            : _visible = YamlUtils.getOptionalSettingAsBool(map, "visible", true),
              _alpha = YamlUtils.getOptionalSettingAsDouble(map, "alpha", 1.0),
              _brightness = YamlUtils.getOptionalSettingAsDouble(map, "brightness", 1.0),
              _contrast = YamlUtils.getOptionalSettingAsDouble(map, "contrast", 1.0),
              _hue = YamlUtils.getOptionalSettingAsDouble(map, "hue", 0.0),
              _saturation = YamlUtils.getOptionalSettingAsDouble(map, "saturation", 1.0),
              _gamma = YamlUtils.getOptionalSettingAsDouble(map, "gamma", 1.0),
              _rectangle = YamlUtils.getOptionalSettingAsList4(map, "rectangle"),
              super(type, name, map);

    @override set visible(bool v) {
        _hub.cesium.setLayerVisible(_layer, v);
        _visible = v;
    }
    @override bool get visible => _visible;

    @override set alpha(double d) {
        _hub.cesium.setLayerAlpha(_layer, d);
        _alpha = d;
    }
    @override double get alpha => _alpha;

    @override set brightness(double d) {
        _hub.cesium.setLayerBrightness(_layer, d);
        _brightness = d;
    }
    @override double get brightness => _brightness;

    @override set contrast(double d) {
        _hub.cesium.setLayerContrast(_layer, d);
        _contrast = d;
    }
    @override double get contrast => _contrast;

    @override set hue(double d) {
        _hub.cesium.setLayerHue(_layer, d);
        _hue = d;
    }
    @override double get hue => _hue;

    @override set saturation(double d) {
        _hub.cesium.setLayerSaturation(_layer, d);
        _saturation = d;
    }
    @override double get saturation => _saturation;

    @override set gamma(double d) {
        _hub.cesium.setLayerGamma(_layer, d);
        _gamma = d;
    }
    @override double get gamma => _gamma;

    void _forceUpdates() {
        visible = _visible;
        alpha = _alpha;
        brightness = _brightness;
        contrast = _contrast;
        hue = _hue;
        saturation = _saturation;
        gamma = _gamma;
    }
}


class SingleImageryLayer extends ImageryLayer {

    SingleImageryLayer(String name, Map map)
            : super("single_imagery", name, map);

    @override
    Future<bool> load() {
        String url = _url.toString();
        String proxy = (_proxy == null) ? null : _proxy.toString();
        _layer = _hub.cesium.addSingleTileImageryProvider(url, _rectangle, proxy);

        _forceUpdates();

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

        _forceUpdates();

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

        _forceUpdates();

        return new Future(() {});
    }
}
