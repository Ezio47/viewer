part of rialto.viewer;

class LineShape extends Shape {
    Vector3 w1 = new Vector3(0.0, 0.0, 0.0);
    Vector3 w2 = new Vector3(10.0, 10.0, 10.0);

    LineShape(RenderingContext gl) : super(gl);

    @override
    void setArrays() {
        var vertices = [];
        var colors = [];
        vertices.addAll([0.0, 0.0, 0.0, 10.0, 10.0, 10.0]);

        vertices.clear();
        vertices.addAll([w1.x, w1.y, w1.z, w2.x, w2.y, w2.z]);

        colors.addAll([1.0, 1.0, 1.0, 1.0]);
        colors.addAll([1.0, 1.0, 1.0, 1.0]);

        vertices.clear();
        vertices.addAll([w1.x, w1.y, w1.z, w2.x, w2.y, w2.z]);

        _vertexArray = new Float32List.fromList(vertices);
        _colorArray = new Float32List.fromList(colors);
        setDefaultIdArray();
    }

    void set(Vector3 p, Vector3 q) {
        if (p==null || q==null) return;
        w1 = p;
        w2 = q;
    }

    @override
    void drawImpl() {
        gl.drawArrays(LINES, 0/*first elem*/, 2/*total num vertices*/);
    }
}
