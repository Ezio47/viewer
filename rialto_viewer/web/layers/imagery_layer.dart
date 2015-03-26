// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

abstract class ImageryLayer extends Layer with VisibilityControl, AlphaControl, ColorCorrectionControl {

    dynamic _layer;
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
            : _visible = ConfigUtils.getOptionalSettingAsBool(map, "visible", true),
              _alpha = ConfigUtils.getOptionalSettingAsDouble(map, "alpha", 1.0),
              _brightness = ConfigUtils.getOptionalSettingAsDouble(map, "brightness", 1.0),
              _contrast = ConfigUtils.getOptionalSettingAsDouble(map, "contrast", 1.0),
              _hue = ConfigUtils.getOptionalSettingAsDouble(map, "hue", 0.0),
              _saturation = ConfigUtils.getOptionalSettingAsDouble(map, "saturation", 1.0),
              _gamma = ConfigUtils.getOptionalSettingAsDouble(map, "gamma", 1.0),
              _rectangle = ConfigUtils.getOptionalSettingAsList4(map, "rectangle"),
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

    @override
    Future unload() {

        var f = new Future(() {
            _hub.cesium.removeImageryLayer(_layer);
        });

        return f;
    }

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
            : super("single_imagery", name, map) {
        _requireUrl();
    }

    @override
    Future load() {
        var f = new Future(() {

            _layer = _hub.cesium.addSingleTileImageryLayer(urlString, _rectangle, proxyString);

            _forceUpdates();
        });
        return f;
    }
}


class WmsImageryLayer extends ImageryLayer {
    String _layers;

    WmsImageryLayer(String name, Map map)
            : super("wms_imagery", name, map),
              _layers = ConfigUtils.getRequiredSettingAsString(map, "layers") {
        _requireUrl();
    }

    @override
    Future load() {
        var f = new Future(() {

            _layer = _hub.cesium.addWebMapServiceImageryLayer(urlString, _layers, _rectangle, proxyString);

            _forceUpdates();
        });
        return f;
    }
}


class TmsImageryLayer extends ImageryLayer {
    int _maximumLevel;
    bool _gdal2Tiles;

    TmsImageryLayer(String name, Map map)
            : super("tms_imagery", name, map),
              _maximumLevel = ConfigUtils.getOptionalSettingAsInt(map, "maximumLevel", 18),
              _gdal2Tiles = ConfigUtils.getOptionalSettingAsBool(map, "gdal2Tiles", false) {
        _requireUrl();
    }

    @override
    Future load() {
        var f = new Future(() {

            _layer =
                    _hub.cesium.addTileMapServiceImageryLayer(urlString, _rectangle, _maximumLevel, _gdal2Tiles, proxyString);

            _forceUpdates();
        });
        return f;
    }
}
