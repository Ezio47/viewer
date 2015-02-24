// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class Commands {
    Hub _hub;

    Commands() :
        _hub = Hub.root;

    Future<Layer> addLayer(LayerData data) {
        return _hub.layerManager.doAddLayer(data);
    }
}
