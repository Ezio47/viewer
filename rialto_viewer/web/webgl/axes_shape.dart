// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class AxesShape extends Shape {
    Float32List _vertexArray;
    Buffer _vertexBuffer;

    Float32List _colorArray;
    Buffer _colorBuffer;

    Float32List _selectionColorArray;
    Buffer _selectionColorBuffer;

    Float32List _selectionMaskArray;
    Buffer _selectionMaskBuffer;

    AxesShape() : super() {
        _initArrays();

        _initBuffers();
    }

    void _initBuffers() {
        _vertexBuffer = gl.createBuffer();
        gl.bindBuffer(ARRAY_BUFFER, _vertexBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _vertexArray, STATIC_DRAW);

        _colorBuffer = gl.createBuffer();
        gl.bindBuffer(ARRAY_BUFFER, _colorBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _colorArray, STATIC_DRAW);

        _selectionColorBuffer = gl.createBuffer();
        gl.bindBuffer(ARRAY_BUFFER, _selectionColorBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _selectionColorArray, STATIC_DRAW);

        _selectionMaskBuffer = gl.createBuffer();
        gl.bindBuffer(ARRAY_BUFFER, _selectionMaskBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _selectionMaskArray, STATIC_DRAW);
    }

    void _initArrays() {
        const double x = 1.0;
        const double y = 1.0;
        const double z = 1.0;

        var vertices = [];
        var colors = [];

        vertices.addAll([0.0, 0.0, 0.0]);
        vertices.addAll([x, 0.0, 0.0]);
        vertices.addAll([0.0, 0.0, 0.0]);
        vertices.addAll([0.0, y, 0.0]);
        vertices.addAll([0.0, 0.0, 0.0]);
        vertices.addAll([0.0, 0.0, z]);

        colors.addAll([1.0, 0.0, 0.0, 1.0]);
        colors.addAll([1.0, 0.0, 0.0, 1.0]);
        colors.addAll([0.0, 1.0, 0.0, 1.0]);
        colors.addAll([0.0, 1.0, 0.0, 1.0]);
        colors.addAll([0.0, 0.0, 1.0, 1.0]);
        colors.addAll([0.0, 0.0, 1.0, 1.0]);

        _vertexArray = new Float32List.fromList(vertices);
        _colorArray = new Float32List.fromList(colors);

        _selectionColorArray = new Float32List(_colorArray.length);
        _selectionMaskArray = new Float32List(_colorArray.length ~/ 4);
        for (int i = 0; i < _colorArray.length ~/ 4; i++) {
            _selectionColorArray[i * 4] = 0.5;
            _selectionColorArray[i * 4 + 1] = 0.5;
            _selectionColorArray[i * 4 + 2] = 0.5;
            _selectionColorArray[i * 4 + 3] = 1.0;
        }
        for (int i = 0; i < _selectionMaskArray.length; i++) {
            _selectionMaskArray[i] = 0.0;
        }
      }

    @override
    void _draw(bool offscreen) {
        if (offscreen) return;

        gl.drawArrays(LINES, 0, _vertexArray.length ~/ 3);
    }

    @override
    void _setBindings(int vertexAttrib, int colorAttrib, int selectionColorAttrib, int selectionMaskAttrib, SetUniformsFunc setUniforms, bool offscreen) {
        if (offscreen) return;

        gl.bindBuffer(ARRAY_BUFFER, _vertexBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _vertexArray, STATIC_DRAW);
        gl.vertexAttribPointer(vertexAttrib, 3/*how many floats per point*/, FLOAT, false, 0/*3*4:bytes*/, 0);

        gl.bindBuffer(ARRAY_BUFFER, _colorBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _colorArray, STATIC_DRAW);
        gl.vertexAttribPointer(colorAttrib, 4, FLOAT, false, 0/*4*4:bytes*/, 0);

        gl.bindBuffer(ARRAY_BUFFER, _selectionColorBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _selectionColorArray, STATIC_DRAW);
        gl.vertexAttribPointer(selectionColorAttrib, 4, FLOAT, false, 0/*4*4:bytes*/, 0);

        gl.bindBuffer(ARRAY_BUFFER, _selectionMaskBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _selectionMaskArray, STATIC_DRAW);
        gl.vertexAttribPointer(selectionMaskAttrib, 1, FLOAT, false, 0/*4*4:bytes*/, 0);

        setUniforms(this, offscreen);
    }
}
