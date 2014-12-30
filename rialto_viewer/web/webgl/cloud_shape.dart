// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class CloudShape extends Shape {
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

    int numPoints;
    Float32List points;
    Float32List colors;

    List<int> selectedPoints = new List<int>();

    CloudShape(RenderingContext gl, Float32List this.points, Float32List this.colors) : super(gl) {
        numPoints = points.length ~/ 3;
        assert(numPoints * 3 == points.length);
        assert(numPoints * 4 == colors.length);

        _initArrays();

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
        gl.bufferDataTyped(ARRAY_BUFFER, _selectionMaskArray, DYNAMIC_DRAW);

        _idBuffer = gl.createBuffer();
        gl.bindBuffer(ARRAY_BUFFER, _idBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _idArray, STATIC_DRAW);
    }

    void _initArrays() {
        _vertexArray = points;
        _colorArray = colors;
        _selectionColorArray = colors;

        //print("${_colorArray.length} ${_vertexArray.length}");
        assert(numPoints * 3 == _vertexArray.length);
        assert(numPoints * 4 == _colorArray.length);

        _idArray = new Float32List(numPoints * 4);
        for (int i = 0,
                j = 0; i < numPoints * 4; i += 4, j += 3) {
            final int pointId = Shape.getNewId();
            var pointCode = Utils.convertIdToFvec(pointId);
            _idArray[i] = pointCode[0];
            _idArray[i + 1] = pointCode[1];
            _idArray[i + 2] = pointCode[2];
            _idArray[i + 3] = pointCode[3];
            Hub.root.shapesMap[pointId] = this;
        }

        _selectionColorArray = new Float32List(numPoints * 4);
        _selectionMaskArray = new Float32List(numPoints);
        for (int i = 0; i < numPoints; i++) {
            _selectionColorArray[i * 4] = 1.0;
            _selectionColorArray[i * 4 + 1] = 1.0;
            _selectionColorArray[i * 4 + 2] = 0.0;
            _selectionColorArray[i * 4 + 3] = 0.0;
        }
        for (int i = 0; i < _selectionMaskArray.length; i++) {
             _selectionMaskArray[i] = 0.0;
         }
      }

    @override
    void _setBindings(int vertexAttrib, int colorAttrib, int selectionColorAttrib, int selectionMaskAttrib,
            SetUniformsFunc setUniforms, bool offscreen) {
        gl.bindBuffer(ARRAY_BUFFER, _vertexBuffer);
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

    @override
    void _draw(bool offscreen) {
        gl.drawArrays(POINTS, 0, numPoints);
    }

    int shapeIdToVertexNum(int shapeId) {
        assert(shapeId > id);
        var vertexNum = shapeId - (id + 1);
        assert(vertexNum >= 0 && vertexNum < numPoints);
        return vertexNum;
    }

    int vertexNumToShapeId(int vertexNum) {
        assert(vertexNum >= 0 && vertexNum < numPoints);
        var shapeId = (id + 1) + vertexNum;
        assert(shapeId > id);
        return shapeId;
    }

    Vector3 getPoint(int shapeId) {
        final int vertexNum = shapeIdToVertexNum(shapeId);

        final double x = _vertexArray[vertexNum * 3];
        final double y = _vertexArray[vertexNum * 3 + 1];
        final double z = _vertexArray[vertexNum * 3 + 2];
        return new Vector3(x, y, z);
    }

    @override
    void pick(int shapeId) {
        print("PICK: $shapeId is ${runtimeType.toString()}");
        final int vertexNum = shapeIdToVertexNum(shapeId);

        _selectionMaskArray[vertexNum] = 1.0;
    }
}
