// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class MeasurementShape extends Shape {
    Float32List _vertexArray;
    Buffer _vertexBuffer;

    Float32List _colorArray;
    Buffer _colorBuffer;

    Float32List _selectionColorArray;
    Buffer _selectionColorBuffer;

    Float32List _selectionMaskArray;
    Buffer _selectionMaskBuffer;

    Buffer _idBuffer;
    Float32List _idArray;

    Vector3 _point1;
    Vector3 _point2;

    MeasurementShape(RenderingContext gl, Vector3 point1, Vector3 point2) : super(gl) {
        _point1 = point1;
        _point2 = point2;

        _initArrays();

        _idArray = Shape._createIdArray(id, _colorArray.length);

        _initBuffers();

        isSelectable = true;
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

        _idBuffer = gl.createBuffer();
        gl.bindBuffer(ARRAY_BUFFER, _idBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _idArray, STATIC_DRAW);
    }

    void _initArrays() {
        double x1 = _point1.x;
        double y1 = _point1.y;
        double z1 = _point1.z;

        double x2 = _point2.x;
        double y2 = _point2.y;
        double z2 = _point2.z;

        final yellow = new Color.yellow().toList();

        final v1 = [x1, y1, z1];
        final v2 = [x2, y2, z2];

        var vertices = [];
        var colors = [];

        // bottom square
        vertices.addAll(v1);
        vertices.addAll(v2);
        colors.addAll(yellow);
        colors.addAll(yellow);

        _vertexArray = new Float32List.fromList(vertices);
        _colorArray = new Float32List.fromList(colors);

        _selectionColorArray = new Float32List(_colorArray.length);
        for (int i = 0; i < _colorArray.length ~/ 4; i++) {
            _selectionColorArray[i * 4] = 0.5;
            _selectionColorArray[i * 4 + 1] = 0.5;
            _selectionColorArray[i * 4 + 2] = 0.5;
            _selectionColorArray[i * 4 + 3] = 1.0;
        }

        _selectionMaskArray = new Float32List(_colorArray.length ~/ 4);
          for (int i = 0; i < _selectionMaskArray.length; i++) {
             _selectionMaskArray[i] = 0.0;
         }
      }

    @override
    void _preDraw(bool offscreen) {
        return;
    }

    @override
    void _postDraw(bool offscreen) {
        return;
    }

    @override
    void _draw(bool offscreen) {
        gl.drawArrays(LINES, 0, _vertexArray.length ~/ 3);
    }

    @override
    void _setBindings(int vertexAttrib, int colorAttrib, int selectionColorAttrib, int selectionMaskAttrib, SetUniformsFunc setUniforms, bool offscreen) {
        gl.bindBuffer(ARRAY_BUFFER, _vertexBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _vertexArray, STATIC_DRAW);
        gl.vertexAttribPointer(vertexAttrib, 3, FLOAT, false, 0, 0);

        if (offscreen) {
            gl.bindBuffer(ARRAY_BUFFER, _idBuffer);
            gl.bufferDataTyped(ARRAY_BUFFER, _idArray, STATIC_DRAW);
            gl.vertexAttribPointer(colorAttrib, 4, FLOAT, false, 0, 0);
        } else {
            gl.bindBuffer(ARRAY_BUFFER, _colorBuffer);
            gl.bufferDataTyped(ARRAY_BUFFER, _colorArray, STATIC_DRAW);
            gl.vertexAttribPointer(colorAttrib, 4, FLOAT, false, 0, 0);
        }

        gl.bindBuffer(ARRAY_BUFFER, _selectionColorBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _selectionColorArray, STATIC_DRAW);
        gl.vertexAttribPointer(selectionColorAttrib, 4, FLOAT, false, 0, 0);

        gl.bindBuffer(ARRAY_BUFFER, _selectionMaskBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _selectionMaskArray, STATIC_DRAW);
        gl.vertexAttribPointer(selectionMaskAttrib, 1, FLOAT, false, 0, 0);

        setUniforms(this, offscreen);
    }

    void pick(int pickedId) {
        for (int i = 0; i < _selectionMaskArray.length; i++) {
            _selectionMaskArray[i] = 1.0;
        }
    }
}
