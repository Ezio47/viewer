// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


part of rialto.viewer;


abstract class BaseImageryLayer extends Layer implements VisibilityControl, AlphaControl, ColorCorrectionControl {

    dynamic _layer;

    bool _visible;
    double _alpha;
    double _brightness;
    double _contrast;
    double _hue;
    double _saturation;
    double _gamma;

    BaseImageryLayer(String type, String name, Map map)
            : _visible = YamlUtils.getOptionalSettingAsBool(map, "visible", true),
              _alpha = YamlUtils.getOptionalSettingAsDouble(map, "alpha", 1.0),
              _brightness = YamlUtils.getOptionalSettingAsDouble(map, "brightness", 1.0),
              _contrast = YamlUtils.getOptionalSettingAsDouble(map, "contrast", 1.0),
              _hue = YamlUtils.getOptionalSettingAsDouble(map, "hue", 0.0),
              _saturation = YamlUtils.getOptionalSettingAsDouble(map, "saturation", 1.0),
              _gamma = YamlUtils.getOptionalSettingAsDouble(map, "gamma", 1.0),
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


class BingBaseImageryLayer extends BaseImageryLayer {

    static final _styles = ['Aerial', 'AerialWithLabels', 'CollinsBart', 'OrdnanceSurvey', 'Road'];
    static const String _defaultStyle = 'Aerial';
    String _style = 'Aerial';
    static const _defaultKey = "ApI13eFfY6SbmvsWx0DbJ1p5C1CaoR54uFc7Bk_Z9Jimwo1SKwCezqvWCskESZaf";
    String _apiKey;

    BingBaseImageryLayer(String name, Map map)
            : _apiKey = YamlUtils.getOptionalSettingAsString(map, "apiKey", _defaultKey),
              _style = YamlUtils.getOptionalSettingAsString(map, "style", _defaultStyle),
              super("bing_base_imagery", name, map) {

        if (!_styles.contains(_style)) {
            throw new ArgumentError("invalid bing style");
        }
    }

    @override
    Future load() {

        var f = new Future(() {
            var options = {
                "key": _apiKey,
                "mapStyle": _style,
                "url": '//dev.virtualearth.net'
            };
            _layer = _hub.cesium.addBingBaseImageryLayer(options);
            _forceUpdates();
        });

        return f;
    }
}


class ArcGisBaseImageryLayer extends BaseImageryLayer {

    ArcGisBaseImageryLayer(String name, Map map)
            : super("arcgis_base_imagery", name, map);

    @override
    Future load() {
        var f = new Future(() {
            var options = {
                "url": '//services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer'
            };
            _layer = _hub.cesium.addArcGisBaseImageryLayer(options);
            _forceUpdates();
        });

        return f;
    }
}


class OsmBaseImageryLayer extends BaseImageryLayer {

    OsmBaseImageryLayer(String name, Map map)
            : super("osm_base_imagery", name, map);

    @override
    Future load() {

        var f = new Future(() {
            var options = {};
            _layer = _hub.cesium.addOsmBaseImageryLayer(options);

            _forceUpdates();
        });
        return f;
    }
}
