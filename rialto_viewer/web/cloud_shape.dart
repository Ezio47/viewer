part of rialto.viewer;

class CloudShape extends Shape {
    int numPoints;
    Float32List points;
    Float32List colors;

    double scaleX = 10.0;
    double scaleY = 10.0;
    double scaleZ = 5.0;
    double offsetX = 0.0;
    double offsetY = 0.0;
    double offsetZ = 0.0;

    CloudShape(RenderingContext gl, Float32List this.points, Float32List this.colors) : super(gl) {
        numPoints = points.length ~/ 3;
    }

    @override
    void setArrays() {
        _vertexArray = new Float32List.fromList(points.toList());

        if (colors == null) {
            var white = new Color.white().toList();
            _colorArray = new Float32List(numPoints * 4);
            for (int i = 0; i < numPoints; i++) {
                colors.addAll(white);
            }
        }

        assert(colors.length == _vertexArray.length);

        _colorArray = new Float32List.fromList(colors);

        print(_colorArray.length ~/ 4);
        _idArray = new Float32List(_colorArray.length);
        for (int i = 0; i < _idArray.length; i += 4) {
            final int pointId = Shape.getNewId();
            var pointCode = Utils.convertIdToFvec(pointId);
            _idArray[i] = pointCode[0];
            _idArray[i + 1] = pointCode[1];
            _idArray[i + 2] = pointCode[2];
            _idArray[i + 3] = pointCode[3];
            Shape.shapes[pointId] = this;
        }
    }

    List<double> makePoints() {
        var rnd = new Random();
        var points = new List<double>();
        int numPoints = 100;
        for (var i = 0; i < numPoints; i++) {
            var x = rnd.nextDouble() * scaleX + offsetX;
            var y = rnd.nextDouble() * scaleY + offsetY;
            var z = rnd.nextDouble() * scaleZ + offsetZ;
            //var x = i - 0.5;
            //var y = 0.5;
            //var z = 0.0;
            points.addAll([x, y, z]);
        }
        return points;
    }

    @override
    void drawImpl() {
        gl.drawArrays(POINTS, 0/*first elem*/, numPoints/*total num vertices*/);
    }
}
