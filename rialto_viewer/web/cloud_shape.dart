part of rialto.viewer;

class CloudShape extends Shape {
    int numPoints;

    double scaleX = 10.0;
    double scaleY = 10.0;
    double scaleZ = 5.0;
    double offsetX = 0.0;
    double offsetY = 0.0;
    double offsetZ = 0.0;

    CloudShape(RenderingContext gl) : super(gl);

    @override
    void setArrays() {
        List<double> points = makePoints();

        numPoints = points.length ~/ 3;
        var vertices = [];
        for (int i = 0; i < points.length; i += 3) {
            double x = points[i];
            double y = points[i + 1];
            double z = points[i + 2];
            vertices.addAll([x, y, z]);
        }

        var colors = [];
        for (int i = 0; i < numPoints; i++) {
            colors.addAll([1.0, 1.0, 1.0, 1.0]);
        }

        _vertexArray = new Float32List.fromList(vertices);
        _colorArray = new Float32List.fromList(colors);

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
