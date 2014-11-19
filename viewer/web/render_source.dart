library render_source;

import 'dart:core';
import 'dart:math' as Math;
import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:typed_data';
import 'rialto_exceptions.dart';
import 'point_cloud.dart';


// given a set of dimensions, as returned by a file load, this class represents
// the cloud itself

class RenderSource {
    var dims = new Map<String, GeometryAttribute>();
    int numPoints;
    Vector3 low, high, avg;
    List<PointCloud> pointClouds = new List<PointCloud>();

    RenderSource();

    void addClouds(List<PointCloud> clouds) {
        for (var cloud in clouds) {
            if (!cloud.hasXYZ) throw new RialtoStateError("point cloud must have X, Y, and Z dimensions");
            pointClouds.add(cloud);
        }

        _createRenderArrays();
        _computeBounds();
    }

    void addCloud(PointCloud cloud) {
        if (!cloud.hasXYZ) throw new RialtoStateError("point cloud must have X, Y, and Z dimensions");
        pointClouds.add(cloud);

        _createRenderArrays();
        _computeBounds();
    }

    void _computeBounds() {
        assert(pointClouds.length > 0);

        double xmin = pointClouds.first.min["positions.x"];
        double ymin = pointClouds.first.min["positions.y"];
        double zmin = pointClouds.first.min["positions.z"];
        double xmax = pointClouds.first.max["positions.x"];
        double ymax = pointClouds.first.max["positions.y"];
        double zmax = pointClouds.first.max["positions.z"];

        int idx = 0;
        for (var cloud in pointClouds) {
            xmin = Math.min(xmin, cloud.min["positions.x"]);
            ymin = Math.min(ymin, cloud.min["positions.y"]);
            zmin = Math.min(zmin, cloud.min["positions.z"]);
            xmax = Math.max(xmax, cloud.max["positions.x"]);
            ymax = Math.max(ymax, cloud.max["positions.y"]);
            zmax = Math.max(zmax, cloud.max["positions.z"]);
        }

        low = new Vector3(xmin, ymin, zmin);
        high = new Vector3(xmax, ymax, zmax);
    }

    void _createRenderArrays() {
        assert(pointClouds.length > 0);

        int sum = 0;
        pointClouds.forEach((p) => sum += p.numPoints);
        numPoints = sum;

        var xyz = new GeometryAttribute.float32(numPoints * 3, 3);
        dims["positions"] = xyz;

        int idx = 0;
        for (var cloud in pointClouds) {
            Float32List xsrc = cloud.dimensions["positions.x"];
            Float32List ysrc = cloud.dimensions["positions.y"];
            Float32List zsrc = cloud.dimensions["positions.z"];
            for (int i = 0; i < cloud.numPoints; i++) {
                xyz.array[idx++] = xsrc[i];
                xyz.array[idx++] = ysrc[i];
                xyz.array[idx++] = zsrc[i];
            }
        }

        var color = new GeometryAttribute.float32(numPoints * 3, 3);
        dims["colors"] = color;
        idx = 0;
        for (var cloud in pointClouds) {
            if (cloud.hasColor3) {
                Float32List xsrc = cloud.dimensions["colors.x"];
                Float32List ysrc = cloud.dimensions["colors.y"];
                Float32List zsrc = cloud.dimensions["colors.z"];
                for (int i = 0; i < cloud.numPoints; i++) {
                    color.array[idx++] = xsrc[i];
                    color.array[idx++] = ysrc[i];
                    color.array[idx++] = zsrc[i];
                }
            } else {
                for (int i = 0; i < cloud.numPoints; i++) {
                    color.array[idx++] = 1.0;
                    color.array[idx++] = 1.0;
                    color.array[idx++] = 1.0;
                }
            }
        }
    }

    void colorize() {
        double zLen = high.z - low.z;

        var positions = dims["positions"].array;
        var colors = dims["colors"].array;

        for (int i = 0; i < numPoints * 3; i += 3) {
            double z = positions[i + 2];
            double c = (z - low.z) / zLen;

            // clip, due to FP math
            assert(c >= -0.1 && c <= 1.1);
            if (c < 0.0) c = 0.0;
            if (c > 1.0) c = 1.0;

            // a silly ramp
            if (c < 0.3333) {
                colors[i] = c * 3.0;
                colors[i + 1] = 0.0;
                colors[i + 2] = 0.0;
            } else if (c < 0.6666) {
                colors[i] = 0.0;
                colors[i + 1] = (c - 0.3333) * 3.0;
                colors[i + 2] = 0.0;
            } else {
                colors[i] = 0.0;
                colors[i + 1] = 0.0;
                colors[i + 2] = (c - 0.6666) * 3.0;
            }
        }
    }
}
