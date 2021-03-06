// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend.private;

abstract class BaseImageryLayer extends Layer implements AlphaControl, ColorCorrectionControl {
  dynamic _layer;

  double _alpha;
  double _brightness;
  double _contrast;
  double _hue;
  double _saturation;
  double _gamma;

  BaseImageryLayer(RialtoBackend backend, String type, String name, Map map)
      : _alpha = ConfigUtils.getOptionalSettingAsDouble(map, "alpha", 1.0),
        _brightness = ConfigUtils.getOptionalSettingAsDouble(map, "brightness", 1.0),
        _contrast = ConfigUtils.getOptionalSettingAsDouble(map, "contrast", 1.0),
        _hue = ConfigUtils.getOptionalSettingAsDouble(map, "hue", 0.0),
        _saturation = ConfigUtils.getOptionalSettingAsDouble(map, "saturation", 1.0),
        _gamma = ConfigUtils.getOptionalSettingAsDouble(map, "gamma", 1.0),
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

class BingBaseImageryLayer extends BaseImageryLayer {
  static final _styles = ['Aerial', 'AerialWithLabels', 'CollinsBart', 'OrdnanceSurvey', 'Road'];
  static const String _defaultStyle = 'Aerial';
  String _style = 'Aerial';
  static const _defaultKey = "ApI13eFfY6SbmvsWx0DbJ1p5C1CaoR54uFc7Bk_Z9Jimwo1SKwCezqvWCskESZaf";
  String _apiKey;

  BingBaseImageryLayer(RialtoBackend backend, String name, Map map)
      : _apiKey = ConfigUtils.getOptionalSettingAsString(map, "apiKey", _defaultKey),
        _style = ConfigUtils.getOptionalSettingAsString(map, "style", _defaultStyle),
        super(backend, "bing_base_imagery", name, map) {
    if (!_styles.contains(_style)) {
      throw new ArgumentError("invalid bing style");
    }
  }

  @override
  Future load() {
    var f = new Future(() {
      var localOptions = {"key": _apiKey, "mapStyle": _style, "url": '//dev.virtualearth.net'};
      _layer = backend.cesium.addBingBaseImageryLayer(localOptions);
      if (!options["isVisible"]) {
        backend.cesium.setLayerVisible(_layer, false);
      }
    });

    return f;
  }
}

class ArcGisBaseImageryLayer extends BaseImageryLayer {
  ArcGisBaseImageryLayer(RialtoBackend backend, String name, Map map)
      : super(backend, "arcgis_base_imagery", name, map);

  @override
  Future load() {
    var f = new Future(() {
      var localOptions = {"url": '//services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer'};
      _layer = backend.cesium.addArcGisBaseImageryLayer(localOptions);
      if (!options["isVisible"]) {
        backend.cesium.setLayerVisible(_layer, false);
      }
    });

    return f;
  }
}

class OsmBaseImageryLayer extends BaseImageryLayer {
  OsmBaseImageryLayer(RialtoBackend backend, String name, Map map) : super(backend, "osm_base_imagery", name, map);

  @override
  Future load() {
    var f = new Future(() {
      var localOptions = {};
      _layer = backend.cesium.addOsmBaseImageryLayer(localOptions);
      if (!options["isVisible"]) {
        backend.cesium.setLayerVisible(_layer, false);
      }
    });
    return f;
  }
}
