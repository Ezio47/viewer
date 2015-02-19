// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class BaseTerrainLayer extends Layer {
    BaseTerrainLayer(String name, Map map)
            : super(name, map);

    @override
    Future<bool> load() {
        var stub = (() {});
        return new Future(stub);
    }
}
