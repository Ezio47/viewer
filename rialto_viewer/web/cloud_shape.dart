part of rialto.viewer;

class CloudShape extends Shape {
    Float32List _vertexArray;
    Buffer _vertexBuffer;

    Float32List _colorArray;
    Buffer _colorBuffer;

    Buffer _idBuffer;
    Float32List _idArray;

    int numPoints;
    Float32List points;
    Float32List colors;

    CloudShape(RenderingContext gl, Float32List this.points, Float32List this.colors) : super(gl) {
        numPoints = points.length ~/ 3;
        assert(numPoints * 3 == points.length);
        assert(numPoints * 4 == colors.length);

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

        _idBuffer = gl.createBuffer();
        gl.bindBuffer(ARRAY_BUFFER, _idBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _idArray, STATIC_DRAW);
    }

    void _initArrays() {
        _vertexArray = points;
        _colorArray = colors;

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

            double x = _vertexArray[j];
            double y = _vertexArray[j + 1];
            double z = _vertexArray[j + 2];
            //print("created point ($id) $pointId == ${pointId - (id+1)} @ ${Utils.printv3(x,y,z,0)}");
        }
    }

    @override
    void _setBindings(int vertexAttrib, int colorAttrib, SetUniformsFunc setUniforms) {
        gl.bindBuffer(ARRAY_BUFFER, _vertexBuffer);
        gl.vertexAttribPointer(vertexAttrib, 3/*how many floats per point*/, FLOAT, false, 0/*3*4:bytes*/, 0);

        if (Hub.root.offscreenMode == 1) {
            gl.bindBuffer(ARRAY_BUFFER, _idBuffer);
            gl.vertexAttribPointer(colorAttrib, 4, FLOAT, false, 0/*4*4:bytes*/, 0);
        } else {
            gl.bindBuffer(ARRAY_BUFFER, _colorBuffer);
            gl.vertexAttribPointer(colorAttrib, 4, FLOAT, false, 0/*4*4:bytes*/, 0);
        }

        if (setUniforms != null) setUniforms(this);
    }

    @override
    void _draw() {
        gl.drawArrays(POINTS, 0/*first elem*/, numPoints/*total num vertices*/);
    }

    Vector3 getPoint(int pickedId) {
        assert(pickedId > id);

        final int objId = id;
        final int pointId = pickedId;
        final int pointNum = pointId - (objId + 1);
        assert(pointNum >= 0 && pointNum < numPoints);

        final double x = _vertexArray[pointNum * 3];
        final double y = _vertexArray[pointNum * 3 + 1];
        final double z = _vertexArray[pointNum * 3 + 2];
        return new Vector3(x, y, z);
    }

    @override
    void pick(int pickedId) {
        print("BOOM: $pickedId is ${runtimeType.toString()}");
        final int objId = id;
        final int pointId = pickedId;
        final int pointNum = pointId - (objId + 1);
        assert(pointNum >= 0 && pointNum < numPoints);

        final double x = _vertexArray[pointNum * 3];
        final double y = _vertexArray[pointNum * 3 + 1];
        final double z = _vertexArray[pointNum * 3 + 2];
        print("read point ($id) $pickedId == $pointNum @ ${Utils.printv3(x,y,z,0)}");
    }
}
