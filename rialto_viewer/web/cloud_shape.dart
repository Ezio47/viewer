part of rialto.viewer;

class CloudShape extends Shape {
    int numPoints;
    Float32List points;
    Float32List colors;

    CloudShape(RenderingContext gl, Float32List this.points, Float32List this.colors) : super(gl) {
        numPoints = points.length ~/ 3;
        assert(numPoints * 3 == points.length);
        assert(numPoints * 4 == colors.length);
    }

    @override
    void setArrays() {
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
            Shape.shapes[pointId] = this;

            double x = _vertexArray[j];
            double y = _vertexArray[j + 1];
            double z = _vertexArray[j + 2];
            print("created point ($id) $pointId == ${pointId - (id+1)} @ ${Utils.printv3(x,y,z,0)}");
        }
    }

    @override
    void drawImpl() {
        gl.drawArrays(POINTS, 0/*first elem*/, numPoints/*total num vertices*/);
    }

    @override
    void defaultPickFunc(int pickedId) {
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
