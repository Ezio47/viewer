// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class BaseImageryLayer extends Layer {

    dynamic _provider;

    static const int _SourceInvalid = 0;
    static const int _SourceBing = 1;
    static const int _SourceArcGis = 2;
    static const int _SourceOsm = 3;
    static final Map<String, int> _sourceMap = {
        'BING': _SourceBing,
        'ARCGIS': _SourceArcGis,
        'OSM': _SourceOsm
    };
    int source;

    static final _bingStyles = ['Aerial', 'AerialWithLabels', 'CollinsBart', 'OrdnanceSurvey', 'Road'];
    static const String _bingDefaultStyle = 'Aerial';
    String _bingStyle = 'Aerial';
    static const _defaultBingKey = "ApI13eFfY6SbmvsWx0DbJ1p5C1CaoR54uFc7Bk_Z9Jimwo1SKwCezqvWCskESZaf";
    String _bingApiKey;

    BaseImageryLayer(String name, Map map)
            : super(name, map),
              _bingApiKey = YamlUtils.getOptionalSettingAsString(map, "bingApiKey", _defaultBingKey),
              _bingStyle = YamlUtils.getOptionalSettingAsString(map, "bingStyle", _bingDefaultStyle) {

        if (!_sourceMap.containsKey(uri.toString())) {
            throw new ArgumentError("invalid base image layer type");
        }
        source = _sourceMap[uri.toString()];
        if (!_bingStyles.contains(_bingStyle)) {
            throw new ArgumentError("invalid bing style");
        }
    }

    @override
    Future<bool> load() {

        switch (source) {

            case _SourceBing:
                _provider = _hub.cesium.setBingBaseImageryProvider(_bingApiKey, _bingStyle);
                break;

            case _SourceArcGis:
                _provider = _hub.cesium.setArcGisBaseImageryProvider();
                break;

            case _SourceOsm:
                _provider = _hub.cesium.setOsmBaseImageryProvider();
                break;

            default:
                throw new ArgumentError("inbalid base imagery source");
        }

        return new Future(() {});
    }
}
