// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

typedef void SetUniformsFunc(Shape shape, bool offscreen);
typedef void PickFunc(int pickedId);

abstract class Shape {
    static int _ids = 257;
    RenderingContext gl;

    String name;
    bool isVisible;
    bool isSelected;
    bool isSelectable;
    int id;

    // to change from model to world coords
    Matrix4 modelMatrix = new Matrix4.identity();

    Shape() {
        id = Shape.getNewId();

        isVisible = true;
        isSelected = false;
        isSelectable = false;

        Hub.root.shapesMap[id] = this;
    }

    static int getNewId() => _ids++;

    void draw(int vertexAttrib, int colorAttrib, int selectionColorAttrib, int selectionMaskAttrib, SetUniformsFunc setUniforms, bool offscreen) {
         if (!isVisible) return;
         _preDraw(offscreen);
         _setBindings(vertexAttrib, colorAttrib, selectionColorAttrib, selectionMaskAttrib, setUniforms, offscreen);
         _draw(offscreen);
         _postDraw(offscreen);
     }

    void _preDraw(bool offscreen) {}

    void _postDraw(bool offscreen) {}

    void pick(int pickedId) {
        assert(id == pickedId);
        print("PICK: $id is ${runtimeType.toString()}");
    }

    void _draw(bool offscreen);

    void _setBindings(int vertexAttrib, int colorAttrib, int selectionColorAttrib, int selectionMaskAttrib, SetUniformsFunc setUniforms, bool offscreen);

    // more renderable objects will use this: it sets the entire object to a single ID
    static Float32List _createIdArray(int id, int length) {
        var pcode = Utils.convertIdToFvec(id);
        Float32List array = new Float32List(length);
        for (int i = 0; i < length; i += 4) {
            array[i] = pcode[0];
            array[i + 1] = pcode[1];
            array[i + 2] = pcode[2];
            array[i + 3] = pcode[3];
        }
        return array;
    }
}
