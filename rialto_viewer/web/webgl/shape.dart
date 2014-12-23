// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

typedef void SetUniformsFunc(Renderable);
typedef void PickFunc(int pickedId);

abstract class Shape {
    static int _ids = 257;
    RenderingContext gl;

    String name;
    bool visible;
    bool highlight;
    int id;

    // to change from model to world coords
    Matrix4 modelMatrix = new Matrix4.identity();

    Shape(RenderingContext this.gl) {
        id = Shape.getNewId();
        visible = true;
        highlight = false;

        Hub.root.shapesMap[id] = this;
    }

    static int getNewId() => _ids++;

    void draw(int vertexAttrib, int colorAttrib, SetUniformsFunc setUniforms) {
         if (!visible) return;
         _setBindings(vertexAttrib, colorAttrib, setUniforms);
         _draw();
     }

    void pick(int pickedId) {
        assert(id == pickedId);
        print("PICK: $id is ${runtimeType.toString()}");
    }

    void _draw();
    void _setBindings(int vertexAttrib, int colorAttrib, SetUniformsFunc setUniforms);

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
