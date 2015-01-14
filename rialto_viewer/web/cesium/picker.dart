// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class Picker {
    Hub _hub;

    Picker() {
        _hub = Hub.root;
    }

    Vector3 getCurrentPoint() {
        return null;
    }

    Shape getCurrentShape() {
        return null;
    }

}
