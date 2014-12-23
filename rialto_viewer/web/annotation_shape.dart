part of rialto.viewer;

class AnnotationShape extends Shape {
    Float32List _vertexArray;
    Buffer _vertexBuffer;

    Float32List _colorArray;
    Buffer _colorBuffer;

    Buffer _idBuffer;
    Float32List _idArray;

    Vector3 _point1;
    Vector3 _point2;

    AnnotationShape(RenderingContext gl, Vector3 point1, Vector3 point2) : super(gl) {
        _point1 = point1;
        _point2 = point2;

        assert(_point1.x <= _point2.x);
        assert(_point1.y <= _point2.y);
        assert(_point1.z == _point2.z);

        _initArrays();

        _idArray = Shape._createIdArray(id, _colorArray.length);

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
    }

    @override
    void _draw() {
        gl.drawArrays(LINES, 0, _vertexArray.length ~/ 3);
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

    void pick(int pickedId) {
        assert(id == pickedId);
        print("BOOM: $id is ${runtimeType.toString()}");
    }

}
