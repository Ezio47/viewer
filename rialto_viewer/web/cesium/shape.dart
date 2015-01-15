// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

typedef void PickFunc(int pickedId);

abstract class Shape {
    static int _ids = 1;

    Hub _hub;
    String name;
    bool isSelected;
    bool isSelectable;
    int id;

    var _primitive;

    Shape(String this.name) {
        _hub = Hub.root;

        id = Shape.getNewId();

        isSelected = false;
        isSelectable = false;

        _hub.shapesMap[id] = this;
    }

    static int getNewId() => _ids++;

    bool get isVisible => _hub.cesium.isPrimitiveVisible(_primitive);

    set isVisible(bool value) => _hub.cesium.setPrimitiveVisible(_primitive, value);

    // result goes into _primitive
    dynamic _createCesiumObject();

    void remove() {
        _hub.cesium.remove(_primitive);
    }

    // called when picked
    void pick(int pickedId) {
        assert(id == pickedId);
        print("PICK: $id is ${runtimeType.toString()}");
    }
}
