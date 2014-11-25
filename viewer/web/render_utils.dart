library render_utils;

import 'dart:core';
import 'package:vector_math/vector_math.dart';
import 'package:three/three.dart';
import 'renderable_point_cloud_set.dart';


class RenderUtils {
    static Line createLine(Vector3 p1, Vector3 p2, int xcolor) {
        var material = new LineBasicMaterial(color: xcolor);

        var geometry = new Geometry();
        geometry.vertices.add(p1);
        geometry.vertices.add(p2);

        var line = new Line(geometry, material);

        return line;
    }

    static Vector3 getCameraPointTarget(RenderablePointCloudSet set) {

        if (set.length == 0) return new Vector3.zero();

        final double x = set.min.x + set.len.x / 2.0;
        final double y = set.min.y + set.len.y / 2.0;
        final double z = set.min.z;

        return new Vector3(x, y, z);
    }

    static Vector3 getCameraPointEye(RenderablePointCloudSet set) {

        if (set.length == 0) return new Vector3(100.0, 100.0, 100.0);

        var v = getCameraPointTarget(set);

        v.x = v.x - 0.5 * set.len.x;
        v.y = v.y - 2.0 * set.len.y;
        v.z = set.max.z * 2.0;

        return v;
    }
}
