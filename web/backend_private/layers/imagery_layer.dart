// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend.private;

abstract class ImageryLayer extends Layer with AlphaControl, ColorCorrectionControl {
  dynamic _layer;
  List<num> _rectangle;

  double _alpha;
  double _brightness;
  double _contrast;
  double _hue;
  double _saturation;
  double _gamma;

  // rect is: w, s, e, n
  ImageryLayer(RialtoBackend backend, String type, String name, Map map)
      : _alpha = ConfigUtils.getOptionalSettingAsDouble(map, "alpha", 1.0),
        _brightness = ConfigUtils.getOptionalSettingAsDouble(map, "brightness", 1.0),
        _contrast = ConfigUtils.getOptionalSettingAsDouble(map, "contrast", 1.0),
        _hue = ConfigUtils.getOptionalSettingAsDouble(map, "hue", 0.0),
        _saturation = ConfigUtils.getOptionalSettingAsDouble(map, "saturation", 1.0),
        _gamma = ConfigUtils.getOptionalSettingAsDouble(map, "gamma", 1.0),
        _rectangle = ConfigUtils.getOptionalSettingAsList4(map, "rectangle"),
        super(backend, type, name, map);

  @override set alpha(double d) {
    backend.cesium.setLayerAlpha(_layer, d);
    _alpha = d;
  }
  @override double get alpha => _alpha;

  @override set brightness(double d) {
    backend.cesium.setLayerBrightness(_layer, d);
    _brightness = d;
  }
  @override double get brightness => _brightness;

  @override set contrast(double d) {
    backend.cesium.setLayerContrast(_layer, d);
    _contrast = d;
  }
  @override double get contrast => _contrast;

  @override set hue(double d) {
    backend.cesium.setLayerHue(_layer, d);
    _hue = d;
  }
  @override double get hue => _hue;

  @override set saturation(double d) {
    backend.cesium.setLayerSaturation(_layer, d);
    _saturation = d;
  }
  @override double get saturation => _saturation;

  @override set gamma(double d) {
    backend.cesium.setLayerGamma(_layer, d);
    _gamma = d;
  }
  @override double get gamma => _gamma;

  @override
  Future unload() {
    var f = new Future(() {
      backend.cesium.removeImageryLayer(_layer);
    });

    return f;
  }
}

class SingleImageryLayer extends ImageryLayer {
  SingleImageryLayer(RialtoBackend backend, String name, Map map) : super(backend, "single_imagery", name, map) {
    requireUrl();
  }

  @override
  Future load() {
    var f = new Future(() {
      _layer = backend.cesium.addSingleTileImageryLayer(urlString, _rectangle, proxyString);
    });
    return f;
  }
}

class WmsImageryLayer extends ImageryLayer {
  String _layers;

  WmsImageryLayer(RialtoBackend backend, String name, Map map)
      : super(backend, "wms_imagery", name, map),
        _layers = ConfigUtils.getRequiredSettingAsString(map, "layers") {
    requireUrl();
  }

  @override
  Future load() {
    var f = new Future(() {
      _layer = backend.cesium.addWebMapServiceImageryLayer(urlString, _layers, _rectangle, proxyString);
    });
    return f;
  }
}

class TmsImageryLayer extends ImageryLayer {
  int _maximumLevel;
  bool _gdal2Tiles;

  TmsImageryLayer(RialtoBackend backend, String name, Map map)
      : super(backend, "tms_imagery", name, map),
        _maximumLevel = ConfigUtils.getOptionalSettingAsInt(map, "maximumLevel", 18),
        _gdal2Tiles = ConfigUtils.getOptionalSettingAsBool(map, "gdal2Tiles", false) {
    requireUrl();
  }

  @override
  Future load() {
    var f = new Future(() {
      _layer =
          backend.cesium.addTileMapServiceImageryLayer(urlString, _rectangle, _maximumLevel, _gdal2Tiles, proxyString);
    });
    return f;
  }
}
