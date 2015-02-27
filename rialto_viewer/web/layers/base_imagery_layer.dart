// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


part of rialto.viewer;


abstract class BaseImageryLayer extends Layer with VisibilityControl, AlphaControl, ColorCorrectionControl {

    dynamic _layer;

    bool _visible;
    double _alpha;
    double _brightness;
    double _contrast;
    double _hue;
    double _saturation;
    double _gamma;

    BaseImageryLayer(String type, String name, Map map)
            : super(type, name, map);

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


class BingBaseImageryLayer extends BaseImageryLayer {

    static final _styles = ['Aerial', 'AerialWithLabels', 'CollinsBart', 'OrdnanceSurvey', 'Road'];
    static const String _defaultStyle = 'Aerial';
    String _style = 'Aerial';
    static const _defaultKey = "ApI13eFfY6SbmvsWx0DbJ1p5C1CaoR54uFc7Bk_Z9Jimwo1SKwCezqvWCskESZaf";
    String _apiKey;

    BingBaseImageryLayer(String name, Map map)
            : super("bing_base_imagery", name, map),
              _apiKey = YamlUtils.getOptionalSettingAsString(map, "apiKey", _defaultKey),
              _style = YamlUtils.getOptionalSettingAsString(map, "style", _defaultStyle) {

        if (!_styles.contains(_style)) {
            throw new ArgumentError("invalid bing style");
        }
    }

    @override
    Future<bool> load() {

        _layer = _hub.cesium.setBingBaseImageryProvider(_apiKey, _style);

        return new Future(() {});
    }
}


class ArcGisBaseImageryLayer extends BaseImageryLayer {

    ArcGisBaseImageryLayer(String name, Map map)
            : super("arcgis_base_imagery", name, map);

    @override
    Future<bool> load() {

        _layer = _hub.cesium.setArcGisBaseImageryProvider();

        return new Future(() {});
    }
}


class OsmBaseImageryLayer extends BaseImageryLayer {

    OsmBaseImageryLayer(String name, Map map)
            : super("osm_base_imagery", name, map);

    @override
    Future<bool> load() {

        _layer = _hub.cesium.setOsmBaseImageryProvider();
        return new Future(() {});
    }
}
