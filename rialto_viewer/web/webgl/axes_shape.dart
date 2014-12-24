// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class AxesShape extends Shape {
    Float32List _vertexArray;
    Buffer _vertexBuffer;

    Float32List _colorArray;
    Buffer _colorBuffer;

    AxesShape(RenderingContext gl) : super(gl) {
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
    }

    @override
    void _draw(bool offscreen) {
        if (offscreen) return;

        gl.drawArrays(LINES, 0, _vertexArray.length ~/ 3);
    }

    @override
    void _setBindings(int vertexAttrib, int colorAttrib, SetUniformsFunc setUniforms, bool offscreen) {
        if (offscreen) return;

        gl.bindBuffer(ARRAY_BUFFER, _vertexBuffer);
        gl.vertexAttribPointer(vertexAttrib, 3/*how many floats per point*/, FLOAT, false, 0/*3*4:bytes*/, 0);

        gl.bindBuffer(ARRAY_BUFFER, _colorBuffer);
        gl.vertexAttribPointer(colorAttrib, 4, FLOAT, false, 0/*4*4:bytes*/, 0);

        setUniforms(this, offscreen);
    }
}
