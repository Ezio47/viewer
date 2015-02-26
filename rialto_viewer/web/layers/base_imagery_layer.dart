// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class BaseImageryLayer extends Layer {

    dynamic _provider;

    static const int _SourceInvalid = 0;
    static const int _SourceBing = 1;
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

        if (uri.toString() == "BING") {
            source = _SourceBing;
            if (!_bingStyles.contains(_bingStyle)) {
                throw new ArgumentError("invalid bing style");
            }

        } else {
            throw new ArgumentError("invalid base image layer type");
        }
    }

    @override
    Future<bool> load() {

        switch (source) {

            case _SourceBing:
                _provider = _hub.cesium.createBingImageryProvider(_bingApiKey, _bingStyle);
                _hub.cesium.addImageryProvider(_provider);
                break;

            default:
                throw new ArgumentError("inbalid base imagery source");
        }

        return new Future(() {});
    }
}
