// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


part of rialto.viewer;


abstract class BaseImageryLayer extends Layer {

    dynamic _layer;

    BaseImageryLayer(String type, String name, Map map)
            : super(type, name, map);
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
