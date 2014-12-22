// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class BoxShape extends Shape {

    BoxShape(RenderingContext gl) : super(gl);

    @override
    void setArrays() {
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
        setDefaultIdArray();
    }

    @override
    void drawImpl() {
        gl.drawArrays(LINES, 0, _vertexArray.length ~/ 3);
    }
}


/***
class BboxObject extends Object3D {
    BboxObject() : super() {
        var x1Geometry = new Geometry()
                ..vertices.add(new Vector3(0.0, 0.0, 0.0))
                ..vertices.add(new Vector3(100.0, 0.0, 0.0));
        var x2Geometry = new Geometry()
                ..vertices.add(new Vector3(0.0, 100.0, 0.0))
                ..vertices.add(new Vector3(100.0, 100.0, 0.0));
        var x3Geometry = new Geometry()
                ..vertices.add(new Vector3(0.0, 0.0, 100.0))
                ..vertices.add(new Vector3(100.0, 0.0, 100.0));
        var x4Geometry = new Geometry()
                ..vertices.add(new Vector3(0.0, 100.0, 100.0))
                ..vertices.add(new Vector3(100.0, 100.0, 100.0));

        var y1Geometry = new Geometry()
                ..vertices.add(new Vector3(0.0, 0.0, 0.0))
                ..vertices.add(new Vector3(0.0, 100.0, 0.0));
        var y2Geometry = new Geometry()
                ..vertices.add(new Vector3(100.0, 0.0, 0.0))
                ..vertices.add(new Vector3(100.0, 100.0, 0.0));
        var y3Geometry = new Geometry()
                ..vertices.add(new Vector3(0.0, 0.0, 100.0))
                ..vertices.add(new Vector3(0.0, 100.0, 100.0));
        var y4Geometry = new Geometry()
                ..vertices.add(new Vector3(100.0, 0.0, 100.0))
                ..vertices.add(new Vector3(100.0, 100.0, 100.0));

        var z1Geometry = new Geometry()
                ..vertices.add(new Vector3(0.0, 0.0, 0.0))
                ..vertices.add(new Vector3(0.0, 0.0, 100.0));
        var z2Geometry = new Geometry()
                ..vertices.add(new Vector3(0.0, 100.0, 0.0))
                ..vertices.add(new Vector3(0.0, 100.0, 100.0));
        var z3Geometry = new Geometry()
                ..vertices.add(new Vector3(100.0, 0.0, 0.0))
                ..vertices.add(new Vector3(100.0, 0.0, 100.0));
        var z4Geometry = new Geometry()
                ..vertices.add(new Vector3(100.0, 100.0, 0.0))
                ..vertices.add(new Vector3(100.0, 100.0, 100.0));

        this.add(new Line(x1Geometry, new LineBasicMaterial(color: 0xff0000)));
        this.add(new Line(x2Geometry, new LineBasicMaterial(color: 0xff0000)));
        this.add(new Line(x3Geometry, new LineBasicMaterial(color: 0xff0000)));
        this.add(new Line(x4Geometry, new LineBasicMaterial(color: 0xff0000)));

        this.add(new Line(y1Geometry, new LineBasicMaterial(color: 0x00ff00)));
        this.add(new Line(y2Geometry, new LineBasicMaterial(color: 0x00ff00)));
        this.add(new Line(y3Geometry, new LineBasicMaterial(color: 0x00ff00)));
        this.add(new Line(y4Geometry, new LineBasicMaterial(color: 0x00ff00)));

        this.add(new Line(z1Geometry, new LineBasicMaterial(color: 0x0000ff)));
        this.add(new Line(z2Geometry, new LineBasicMaterial(color: 0x0000ff)));
        this.add(new Line(z3Geometry, new LineBasicMaterial(color: 0x0000ff)));
        this.add(new Line(z4Geometry, new LineBasicMaterial(color: 0x0000ff)));

        // radius top, radius bottom, height, segments-radius, segments-height
        var sphereGeometry = new SphereGeometry(2.0);

        var sphere = new Mesh(sphereGeometry, new MeshBasicMaterial(color: 0x808080));
        sphere.position = new Vector3(0.0, 0.0, 0.0);
        this.add(sphere);

    }
}
***/
