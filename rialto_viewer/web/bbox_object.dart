// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


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
