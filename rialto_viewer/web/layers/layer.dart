// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


abstract class Layer {
    final Hub _hub;

    final String name;
    final Uri uri;
    final String description;
    final String _proxy;

    bool _visible;
    CartographicBbox _bbox;

    Layer(String this.name, Map map)
            : _hub = Hub.root,
              uri = YamlUtils.getRequiredSettingAsUri(map, "url"),
              description = YamlUtils.getOptionalSettingAsString(map, "description"),
              _visible = YamlUtils.getOptionalSettingAsBool(map, "visible", true),
              _proxy = YamlUtils.getOptionalSettingAsString(map, "proxy", null);

    Future<bool> load();

    bool get visible => _visible;
    set visible(bool v) => _visible = v;

    CartographicBbox get bbox => _bbox;
    set bbox(CartographicBbox bbox) => _bbox = bbox;

    // some of the Cesium examples use URLs with the "http" part removed, so...
    static String removeScheme(String s) {
        return s;
        if (s.startsWith("http:")) {
            s = s.substring(5);
        } else if (s.startsWith("https:")) {
                s = s.substring(6);
        }
        return s;
    }
}
