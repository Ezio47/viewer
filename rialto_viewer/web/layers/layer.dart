// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


abstract class Layer {
    final Hub _hub;

    final String type;
    final String name;
    final String description;

    CartographicBbox _bbox;

    Layer(String this.type, String this.name, Map map)
            : _hub = Hub.root,
              description = YamlUtils.getOptionalSettingAsString(map, "description") {
        log("New $type layer: $name");
    }

    Future load();

    CartographicBbox get bbox => _bbox;
}


abstract class UrlLayer extends Layer {
    Uri _url;
    Uri _proxy;

    UrlLayer(String type, String name, Map map)
            : super(type, name, map) {
        _url = YamlUtils.getOptionalSettingAsUrl(map, "url");
        _proxy = YamlUtils.getOptionalSettingAsUrl(map, "proxy");
    }

    Uri get url => _url;
    Uri get proxy => _proxy;
}


abstract class VisibilityControl {
    bool get visible;
    set visible(bool v);
}


abstract class AlphaControl {
    double get alpha;
    set alpha(double d);
}


abstract class ColorCorrectionControl {
    double get brightness;
    set brightness(double d);

    double get contrast;
    set contrast(double d);

    double get hue;
    set hue(double d);

    double get saturation;
    set saturation(double d);

    double get gamma;
    set gamma(double d);
}


abstract class ColorizerControl {
    ColorizerData get colorizerData;
    set colorizerData(ColorizerData data);
}
