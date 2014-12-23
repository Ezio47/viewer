part of rialto.viewer;

class AnnotationShape extends Shape {
    Vector3 _point1;
    Vector3 _point2;

    AnnotationShape(RenderingContext gl, Vector3 point1, Vector3 point2) : super(gl) {
        _point1 = point1;
        _point2 = point2;

        assert(_point1.x <= _point2.x);
        assert(_point1.y <= _point2.y);
        assert(_point1.z == _point2.z);
    }

    @override
    void setArrays() {
        double x1 = _point1.x;
        double y1 = _point1.y;
        double z1 = _point1.z;

        double x3 = _point2.x;
        double y3 = _point2.y;
        double z3 = _point2.z;

        double x2 = _point1.x;
        double y2 = _point2.y;
        double z2 = _point1.z;

        double x4 = _point2.x;
        double y4 = _point1.y;
        double z4 = _point2.z;

        final yellow = new Color.yellow().toList();

        final v1 = [x1, y1, z1];
        final v2 = [x2, y2, z2];
        final v3 = [x3, y3, z3];
        final v4 = [x4, y4, z4];

        var vertices = [];
        var colors = [];

        // bottom square
        vertices.addAll(v1);
        vertices.addAll(v2);
        colors.addAll(yellow);
        colors.addAll(yellow);

        vertices.addAll(v2);
        vertices.addAll(v3);
        colors.addAll(yellow);
        colors.addAll(yellow);

        vertices.addAll(v3);
        vertices.addAll(v4);
        colors.addAll(yellow);
        colors.addAll(yellow);

        vertices.addAll(v4);
        vertices.addAll(v1);
        colors.addAll(yellow);
        colors.addAll(yellow);

        _vertexArray = new Float32List.fromList(vertices);
        _colorArray = new Float32List.fromList(colors);
        setDefaultIdArray();
    }

    @override
    void drawImpl() {
        gl.drawArrays(LINES, 0, _vertexArray.length ~/ 3);
    }
}
