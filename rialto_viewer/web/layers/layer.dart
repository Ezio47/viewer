// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


abstract class Layer {
    final Hub _hub;

    final String type;
    final String name;
    final String description;

    final Uri url;
    final Uri proxy;

    CartographicBbox _bbox;

    Layer(String this.type, String this.name, Map map)
            : _hub = Hub.root,
              url = YamlUtils.getOptionalSettingAsUrl(map, "url"),
              proxy = YamlUtils.getOptionalSettingAsUrl(map, "proxy"),
              description = YamlUtils.getOptionalSettingAsString(map, "description");
    _requireUrl() {
        if (url != null) return;
        throw new ArgumentError("url not set in config file");
    }

    String get urlString => url.toString();
    String get proxyString => (proxy == null) ? null : proxy.toString();

    Future load(); // "add"
    Future unload(); // "remove"

    CartographicBbox get bbox => _bbox;

    bool get canZoomTo => (bbox != null);
}


abstract class VisibilityControl {
    bool get visible;
    set visible(bool v);
}


abstract class BboxVisibilityControl {
    bool get bboxVisible;
    set bboxVisible(bool v);
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
