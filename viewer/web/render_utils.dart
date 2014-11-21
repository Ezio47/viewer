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

        // centered directly above, a few Z-units up
        final double x = cloud.min.x + cloud.len.x / 2.0;
        final double y = cloud.min.y + cloud.len.y / 2.0;
        final double z = cloud.min.z;

        return new Vector3(cloud.min.x, cloud.min.y, cloud.min.z);
    }

    static Vector3 getCameraPointAbove(RenderSource cloud) {

        // centered directly above, a few Z-units up
        /*
        final double x = cloud.min.x + cloud.len.x / 2.0;
        final double y = cloud.min.y + cloud.len.y / 2.0;
        final double z = cloud.max.z + 5 * cloud.len.z;
        */
        var v = getCameraPointTarget(cloud);
        final double d = Math.max(cloud.len.x, cloud.len.y);
        v.z += 2 * d;

        v.x = cloud.max.x * 1.5;//+ cloud.len.x / 2.0;
        v.y = cloud.max.y * 1.4;//+ cloud.len.y / 2.0;
        v.z = cloud.max.z * 1.6 ;//* cloud.len.z;

        return v;
    }

    static Vector3 getCameraPointAngled(RenderSource cloud) {
        // when we change the cloud, we need to change where the camera is

        // from origin,
        // 1/2 unit to right (+x)
        // 1 unit towards viewer (-y)
        // 3 units up (+z)

        var v = getCameraPointTarget(cloud);
        final double x = cloud.min.x + cloud.len.x / 2;
        final double y = cloud.min.y - cloud.len.y * 1;
        final double z = cloud.max.z + 3 * cloud.len.z;

        return new Vector3(x, y, z);
    }
}
