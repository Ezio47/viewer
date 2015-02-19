// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


abstract class Layer {
    Hub _hub;

    String name;
    String server;
    String path;
    String description;
    bool isVisible;
    CartographicBbox bbox;

    Layer(String this.name, Map map) {
        _hub = Hub.root;

        server = YamlUtils.getRequiredSettingAsString(map, "server");
        path = YamlUtils.getRequiredSettingAsString(map, "path");
        description = YamlUtils.getOptionalSettingAsString(map, "description");
        isVisible = YamlUtils.getOptionalSettingAsBool(map, "visible", true);
    }

    void changeVisibility(bool v) {
        isVisible = v;
    }

    Future<bool> load() {
        var stub = (() {});
        return new Future(stub);
    }
}
