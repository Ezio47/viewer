// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

typedef void SetUniformsFunc(Shape shape, bool offscreen);
typedef void PickFunc(int pickedId);

abstract class Shape {
    static int _ids = 257;

    Hub _hub;
    String name;
    bool isVisible;
    bool isSelected;
    bool isSelectable;
    int id;

    var _csPrimitive;

    Shape() {
        _hub = Hub.root;

        id = Shape.getNewId();

        isVisible = true;
        isSelected = false;
        isSelectable = false;

        Hub.root.shapesMap[id] = this;

        _createCesiumObject();
        assert(_csPrimitive != null);
    }

    static int getNewId() => _ids++;

    // should set _csPrimitive
    void _createCesiumObject();

    // called when picked
    void pick(int pickedId) {
        assert(id == pickedId);
        print("PICK: $id is ${runtimeType.toString()}");
    }
}
