// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class AxesShape extends Shape {
    AxesShape(RenderingContext gl) : super(gl);

    @override
    void setArrays() {
        const double x = 1.0;
        const double y = 1.0;
        const double z = 1.0;
        var vertices = [];
        vertices.addAll([0.0, 0.0, 0.0, x, 0.0, 0.0]);
        vertices.addAll([0.0, 0.0, 0.0, 0.0, y, 0.0]);
        vertices.addAll([0.0, 0.0, 0.0, 0.0, 0.0, z]);

        var colors = [];
        colors.addAll([1.0, 0.0, 0.0, 1.0]);
        colors.addAll([1.0, 0.0, 0.0, 1.0]);
        colors.addAll([0.0, 1.0, 0.0, 1.0]);
        colors.addAll([0.0, 1.0, 0.0, 1.0]);
        colors.addAll([0.0, 0.0, 1.0, 1.0]);
        colors.addAll([0.0, 0.0, 1.0, 1.0]);

        _vertexArray = new Float32List.fromList(vertices);
        _colorArray = new Float32List.fromList(colors);

        setDefaultIdArray();
    }

    @override
    void drawImpl() {
        gl.drawArrays(LINES, 0/*first elem*/, 6/*total num vertices*/);
    }
}

/***
// taken from three/extra/helpers/axis_helper.dart
class AxesObject extends Object3D {
    AxesObject() : super() {

        var lineGeometry = new Geometry();
        lineGeometry.vertices.add(new Vector3.zero());
        lineGeometry.vertices.add(new Vector3(0.0, 100.0, 0.0));

        // radius top, radius bottom, height, segments-radius, segments-height
        var coneGeometry = new CylinderGeometry(0.0, 10.0, 20.0, 8, 1);

        var line, cone;

        // x

        line = new Line(lineGeometry, new LineBasicMaterial(color: 0xff0000));
        line.rotation.z = -Math.PI / 2.0;
        this.add(line);

        cone = new Mesh(coneGeometry, new MeshBasicMaterial(color: 0xff0000));
        cone.position.x = 100.0;
        cone.rotation.z = -Math.PI / 2.0;
        this.add(cone);

        // y

        line = new Line(lineGeometry, new LineBasicMaterial(color: 0x00ff00));
        this.add(line);

        cone = new Mesh(coneGeometry, new MeshBasicMaterial(color: 0x00ff00));
        cone.position.y = 100.0;
        this.add(cone);

        // z

        line = new Line(lineGeometry, new LineBasicMaterial(color: 0x0000ff));
        line.rotation.x = Math.PI / 2.0;
        this.add(line);

        cone = new Mesh(coneGeometry, new MeshBasicMaterial(color: 0x0000ff));
        cone.position.z = 100.0;
        cone.rotation.x = Math.PI / 2.0;
        this.add(cone);
    }
}
 ***/
