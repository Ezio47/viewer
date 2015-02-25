// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class BaseImageryLayer extends Layer {
    static const String defaultBingKey = "ApI13eFfY6SbmvsWx0DbJ1p5C1CaoR54uFc7Bk_Z9Jimwo1SKwCezqvWCskESZaf";

    dynamic _provider;
    String apiKey;

    BaseImageryLayer(String name, Map map)
            : super(name, map),
            apiKey = YamlUtils.getOptionalSettingAsString(map, "apiKey", defaultBingKey) {

        if (server == "BING") {

        } else {
            throw new ArgumentError("invalid base image layer type");
        }
    }

    @override
    Future<bool> load() {

        _provider = _hub.cesium.createBingImageryProvider(apiKey);
        _hub.cesium.addImageryProvider(_provider);

        return new Future((){});
    }
}
