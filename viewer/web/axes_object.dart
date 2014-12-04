library axes_object;

import 'dart:core';
import 'dart:math' as Math;
import 'package:vector_math/vector_math.dart';
import 'package:three/three.dart' as three;

// taken from three/extra/helpers/axis_helper.dart
class AxesObject extends three.Object3D {
    AxesObject() : super() {

        var lineGeometry = new three.Geometry();
        lineGeometry.vertices.add(new Vector3.zero());
        lineGeometry.vertices.add(new Vector3(0.0, 100.0, 0.0));

        // radius top, radius bottom, height, segments-radius, segments-height
        var coneGeometry = new three.CylinderGeometry(0.0, 3.0, 10.0, 8, 1);

        var line, cone;

        // x

        line = new three.Line(lineGeometry, new three.LineBasicMaterial(color: 0xff0000));
        line.rotation.z = -Math.PI / 2.0;
        this.add(line);

        cone = new three.Mesh(coneGeometry, new three.MeshBasicMaterial(color: 0xff0000));
        cone.position.x = 100.0;
        cone.rotation.z = -Math.PI / 2.0;
        this.add(cone);

        // y

        line = new three.Line(lineGeometry, new three.LineBasicMaterial(color: 0x00ff00));
        this.add(line);

        cone = new three.Mesh(coneGeometry, new three.MeshBasicMaterial(color: 0x00ff00));
        cone.position.y = 100.0;
        this.add(cone);

        // z

        line = new three.Line(lineGeometry, new three.LineBasicMaterial(color: 0x0000ff));
        line.rotation.x = Math.PI / 2.0;
        this.add(line);

        cone = new three.Mesh(coneGeometry, new three.MeshBasicMaterial(color: 0x0000ff));
        cone.position.z = 100.0;
        cone.rotation.x = Math.PI / 2.0;
        this.add(cone);
    }
}
