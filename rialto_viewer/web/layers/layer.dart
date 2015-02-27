// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


abstract class Layer {
    final Hub _hub;

    final String type;
    final String name;
    final String description;

    bool _visible;
    CartographicBbox _bbox;

    Layer(String this.type, String this.name, Map map)
            : _hub = Hub.root,
              description = YamlUtils.getOptionalSettingAsString(map, "description"),
              _visible = YamlUtils.getOptionalSettingAsBool(map, "visible", true) {
        log("New $type layer: $name");
    }

    Future<bool> load();

    bool get visible => _visible;
    set visible(bool v) => _visible = v;

    CartographicBbox get bbox => _bbox;
    set bbox(CartographicBbox bbox) => _bbox = bbox;
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
