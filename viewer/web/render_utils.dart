library render_utils;

import 'dart:core';
import 'dart:math' as Math;
import 'package:vector_math/vector_math.dart';
import 'package:three/three.dart';
import 'utils.dart';
import 'render_source.dart';


class RenderUtils {
    static Line createLine(Vector3 p1, Vector3 p2, int xcolor) {
        var material = new LineBasicMaterial(color: xcolor);

        var geometry = new Geometry();
        geometry.vertices.add(p1);
        geometry.vertices.add(p2);

        var line = new Line(geometry, material);

        return line;
    }

    static ParticleSystem drawPoints(RenderSource cloud) {
        var positions = cloud.dims["positions"];
        var colors = cloud.dims["colors"];
        assert(positions != null);
        assert(colors != null);

        // the underlying system wants to take ownership of these arrays, so we'll
        // pass them copies
        BufferGeometry geometry = new BufferGeometry();
        geometry.attributes = {
            "position": Utils.clone(positions),
            "color": Utils.clone(colors)
        };

        geometry.computeBoundingSphere();
        var material = new ParticleBasicMaterial(size: 1, vertexColors: 2);

        var particleSystem = new ParticleSystem(geometry, material);

        return particleSystem;
    }

    static Vector3 getCameraPointTarget(RenderSource cloud) {

        final double x = cloud.min.x + cloud.len.x / 2.0;
        final double y = cloud.min.y + cloud.len.y / 2.0;
        final double z = cloud.min.z;

        return new Vector3(x, y, z);
    }

    static Vector3 getCameraPointEye(RenderSource cloud) {

        var v = getCameraPointTarget(cloud);

        v.x = v.x - 0.5 * cloud.len.x;
        v.y = v.y - 2.0 * cloud.len.y;
        v.z = cloud.max.z * 2.0;

        return v;
    }
}
