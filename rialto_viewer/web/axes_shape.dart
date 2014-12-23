// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class AxesShape extends BasicShape {
    Float32List _vertexArray;
    Buffer _vertexBuffer;

    Float32List _colorArray;
    Buffer _colorBuffer;
    Float32List _highlightColorArray;
    Buffer _highlightColorBuffer;

    Buffer _idBuffer;
    Float32List _idArray;

    AxesShape(RenderingContext gl) : super(gl) {
        _initArrays();

        assert(_vertexArray != null);
        assert(_colorArray != null);
        assert(_idArray != null);

        _initBuffers();

        var pcode = Utils.convertIdToFvec(id);
        //print("created ${this.runtimeType}: $id ($pcode)");
    }

    void _initBuffers() {
        _vertexBuffer = gl.createBuffer();
        gl.bindBuffer(ARRAY_BUFFER, _vertexBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _vertexArray, STATIC_DRAW);

        _colorBuffer = gl.createBuffer();
        gl.bindBuffer(ARRAY_BUFFER, _colorBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _colorArray, STATIC_DRAW);

        _highlightColorBuffer = gl.createBuffer();
        gl.bindBuffer(ARRAY_BUFFER, _highlightColorBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _highlightColorArray, STATIC_DRAW);

        _idBuffer = gl.createBuffer();
        gl.bindBuffer(ARRAY_BUFFER, _idBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _idArray, STATIC_DRAW);
    }

    void _initArrays() {
        const double x = 1.0;
        const double y = 1.0;
        const double z = 1.0;
        var vertices = [];
        vertices.addAll([0.0, 0.0, 0.0, x, 0.0, 0.0]);
        vertices.addAll([0.0, 0.0, 0.0, 0.0, y, 0.0]);
        vertices.addAll([0.0, 0.0, 0.0, 0.0, 0.0, z]);

        var colors = [];
        colors.addAll([1.0, 0.0, 0.0, 1.0]);
        colors.addAll([1.0, 0.0, 0.0, 1.0]);
        colors.addAll([0.0, 1.0, 0.0, 1.0]);
        colors.addAll([0.0, 1.0, 0.0, 1.0]);
        colors.addAll([0.0, 0.0, 1.0, 1.0]);
        colors.addAll([0.0, 0.0, 1.0, 1.0]);

        _vertexArray = new Float32List.fromList(vertices);
        _colorArray = new Float32List.fromList(colors);

        _idArray = _createIdArray(_colorArray.length);
    }

    @override
    void _drawImpl() {
        gl.drawArrays(LINES, 0, _vertexArray.length ~/ 3);

    }

    @override
    void _setBindings(int vertexAttrib, int colorAttrib, SetUniformsFunc setUniforms) {
        gl.bindBuffer(ARRAY_BUFFER, _vertexBuffer);
        gl.vertexAttribPointer(vertexAttrib, 3/*how many floats per point*/, FLOAT, false, 0/*3*4:bytes*/, 0);

        if (BasicShape.offscreen == 1) {
            gl.bindBuffer(ARRAY_BUFFER, _idBuffer);
            gl.vertexAttribPointer(colorAttrib, 4, FLOAT, false, 0/*4*4:bytes*/, 0);
        } else {
            gl.bindBuffer(ARRAY_BUFFER, _colorBuffer);
            gl.vertexAttribPointer(colorAttrib, 4, FLOAT, false, 0/*4*4:bytes*/, 0);
        }

        assert(setUniforms != null);
        setUniforms(this);
    }

    void pick(int pickedId) {
        assert(id == pickedId);
        print("BOOM: $id is ${runtimeType.toString()}");
    }
}
