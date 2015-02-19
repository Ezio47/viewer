// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


abstract class Layer {
    final Hub _hub;

    final String name;
    final String server;
    final String path;
    final String description;

    bool _isVisible;
    CartographicBbox _bbox;

    Layer(String this.name, Map map)
            : _hub = Hub.root,
              server = YamlUtils.getRequiredSettingAsString(map, "server"),
              path = YamlUtils.getRequiredSettingAsString(map, "path"),
              description = YamlUtils.getOptionalSettingAsString(map, "description"),
              _isVisible = YamlUtils.getOptionalSettingAsBool(map, "visible", true);

    Future<bool> load();

    bool get visible => _isVisible;
    set visible(bool v) => _isVisible = v;

    CartographicBbox get bbox => _bbox;
    set bbox(CartographicBbox bbox) => _bbox = bbox;
}
