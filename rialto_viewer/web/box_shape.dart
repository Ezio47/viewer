// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class BoxShape extends Shape {

    BoxShape(RenderingContext gl) : super(gl);

    @override
    void setArrays() {
        const double x = 10.0;
        const double y = 10.0;
        const double z = 10.0;
        const double xx = 11.0;
        const double yy = 11.0;
        const double zz = 11.0;
        var vertices = [];
        var a = [x, y, z];
        var b = [xx, y, z];
        var c = [x, yy, z];
        var d = [xx, yy, z];
        var aa = [x, y, zz];
        var bb = [xx, y, zz];
        var cc = [x, yy, zz];
        var dd = [xx, yy, zz];

        vertices.addAll(a);
        vertices.addAll(b);
        vertices.addAll(b);
        vertices.addAll(d);
        vertices.addAll(d);
        vertices.addAll(c);
        vertices.addAll(c);
        vertices.addAll(a);

        vertices.addAll(aa);
        vertices.addAll(bb);
        vertices.addAll(bb);
        vertices.addAll(dd);
        vertices.addAll(dd);
        vertices.addAll(cc);
        vertices.addAll(cc);
        vertices.addAll(aa);

        vertices.addAll(a);
        vertices.addAll(aa);
        vertices.addAll(b);
        vertices.addAll(bb);
        vertices.addAll(c);
        vertices.addAll(cc);
        vertices.addAll(d);
        vertices.addAll(dd);

        var colors = [];
        for (int i = 0; i < 8 + 8 + 8; i++) {
            colors.addAll([1.0, 1.0, 1.0, 1.0]);
        }

        _vertexArray = new Float32List.fromList(vertices);
        _colorArray = new Float32List.fromList(colors);
        setDefaultIdArray();
    }

    @override
    void drawImpl() {
        gl.drawArrays(LINES, 0/*first elem*/, 8 + 8 + 8/*total num vertices*/);
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
