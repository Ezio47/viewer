// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class BoxShape extends Shape {

    Float32List _vertexArray;
    Buffer _vertexBuffer;

    Float32List _colorArray;
    Buffer _colorBuffer;

    Buffer _idBuffer;
    Float32List _idArray;

    BoxShape(RenderingContext gl) : super(gl) {
        _initArrays();

        _idArray = Shape._createIdArray(id, _colorArray.length);

        _initBuffers();
    }

    void _initBuffers() {
        assert(_vertexArray != null);
        assert(_colorArray != null);
        assert(_idArray != null);

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
        const double x = 0.0;
        const double y = 0.0;
        const double z = 0.0;
        const double xx = 1.0;
        const double yy = 1.0;
        const double zz = 1.0;

        final red = new Color.red().toList();
        final blue = new Color.blue().toList();
        final green = new Color.green().toList();

        final a = [x, y, z];
        final b = [xx, y, z];
        final c = [x, yy, z];
        final d = [xx, yy, z];
        final aa = [x, y, zz];
        final bb = [xx, y, zz];
        final cc = [x, yy, zz];
        final dd = [xx, yy, zz];

        var vertices = [];
        var colors = [];

        // bottom square
        vertices.addAll(a); // 0
        vertices.addAll(b); // 1
        colors.addAll(red);
        colors.addAll(red);

        vertices.addAll(b); // 2
        vertices.addAll(d); // 3
        colors.addAll(green);
        colors.addAll(green);

        vertices.addAll(d); // 4
        vertices.addAll(c); // 5
        colors.addAll(red);
        colors.addAll(red);

        vertices.addAll(c); // 6
        vertices.addAll(a); // 7
        colors.addAll(green);
        colors.addAll(green);

        // top square
        vertices.addAll(aa); // 8
        vertices.addAll(bb); // 9
        colors.addAll(red);
        colors.addAll(red);

        vertices.addAll(bb); // 10
        vertices.addAll(dd); // 11
        colors.addAll(green);
        colors.addAll(green);

        vertices.addAll(dd); // 12
        vertices.addAll(cc); // 13
        colors.addAll(red);
        colors.addAll(red);

        vertices.addAll(cc);
        vertices.addAll(aa);
        colors.addAll(green);
        colors.addAll(green);

        // vertical lines
        vertices.addAll(a);
        vertices.addAll(aa);
        colors.addAll(blue);
        colors.addAll(blue);

        vertices.addAll(b);
        vertices.addAll(bb);
        colors.addAll(blue);
        colors.addAll(blue);

        vertices.addAll(c);
        vertices.addAll(cc);
        colors.addAll(blue);
        colors.addAll(blue);

        vertices.addAll(d);
        vertices.addAll(dd);
        colors.addAll(blue);
        colors.addAll(blue);

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
