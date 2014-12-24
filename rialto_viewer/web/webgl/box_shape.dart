// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class BoxShape extends Shape {
    int numVertices;

    Float32List _vertexArray;
    Buffer _vertexBuffer;

    Float32List _colorArray;
    Buffer _colorBuffer;

    BoxShape(RenderingContext gl) : super(gl) {
        _initArrays();

        _initBuffers();
    }

    void _initBuffers() {
        assert(_vertexArray != null);
        assert(_colorArray != null);

        _vertexBuffer = gl.createBuffer();
        gl.bindBuffer(ARRAY_BUFFER, _vertexBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _vertexArray, STATIC_DRAW);

        _colorBuffer = gl.createBuffer();
        gl.bindBuffer(ARRAY_BUFFER, _colorBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _colorArray, STATIC_DRAW);
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
        final white = new Color.white().toList();

        final o = [0.0, 0.0, 0.0];
        final xo = [0.1, 0.0, 0.0];
        final yo = [0.0, 0.1, 0.0];
        final zo = [0.0, 0.0, 0.1];

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

        // origin axes
        vertices.addAll(o);
        vertices.addAll(xo);
        vertices.addAll(o);
        vertices.addAll(yo);
        vertices.addAll(o);
        vertices.addAll(zo);
        colors.addAll(white);
        colors.addAll(white);
        colors.addAll(white);
        colors.addAll(white);
        colors.addAll(white);
        colors.addAll(white);

        // bottom square
        vertices.addAll(xo); // 0
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
        vertices.addAll(yo); // 7
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
        vertices.addAll(zo);
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

        numVertices = _vertexArray.length ~/ 3;
    }

    @override
    void _draw(bool offscreen) {
        if (offscreen) return;

        gl.drawArrays(LINES, 0, numVertices);
    }

    @override
    void _setBindings(int vertexAttrib, int colorAttrib, SetUniformsFunc setUniforms, bool offscreen) {
        if (offscreen) return;

        gl.bindBuffer(ARRAY_BUFFER, _vertexBuffer);
        gl.vertexAttribPointer(vertexAttrib, 3, FLOAT, false, 0, 0);

        gl.bindBuffer(ARRAY_BUFFER, _colorBuffer);
        gl.vertexAttribPointer(colorAttrib, 4, FLOAT, false, 0, 0);

        setUniforms(this, offscreen);
    }
}
