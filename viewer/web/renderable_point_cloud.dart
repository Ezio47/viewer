library renderable_point_cloud;

import 'dart:core';
import 'package:three/three.dart';
import 'dart:math' as Math;
import 'package:vector_math/vector_math.dart';
import 'dart:typed_data';

// given a set of dimensions, as returned by FileGenerator, this class represents
// the cloud itself

class RenderablePointCloud {
    Map<String, GeometryAttribute> dims = new Map<String, GeometryAttribute>();
    int numPoints;
    Vector3 low, high, avg;

    RenderablePointCloud(Map<String, Float32List> mydims) {
        _checkValid(mydims);

        numPoints = mydims["positions.x"].length;

        var xdata = _computeBounds(mydims["positions.x"]);
        var ydata = _computeBounds(mydims["positions.y"]);
        var zdata = _computeBounds(mydims["positions.z"]);
        low = new Vector3(xdata[0], ydata[0], zdata[0]);
        high = new Vector3(xdata[1], ydata[1], zdata[1]);
        avg = new Vector3(xdata[2], ydata[2], zdata[2]);

        _convertArrays(mydims);
    }


    GeometryAttribute _convertArray3(Float32List src1, Float32List src2, Float32List src3) {
        var dst = new GeometryAttribute.float32(numPoints * 3, 3);

        for (int i = 0; i < numPoints; i++) {
            dst.array[i * 3 + 0] = src1[i];
            dst.array[i * 3 + 1] = src2[i];
            dst.array[i * 3 + 2] = src3[i];
        }

        return dst;
    }


    void _convertArrays(Map<String, Float32List> mydims) {
        dims["positions"] = _convertArray3(mydims["positions.x"], mydims["positions.y"], mydims["positions.z"]);

        if (mydims.containsKey("colors.x")) {
            dims["colors"] = _convertArray3(mydims["colors.x"], mydims["colors.y"], mydims["colors.z"]);
        } else {
            var colors = new GeometryAttribute.float32(numPoints * 3, 3);
            dims["colors"] = colors;
            for (int i = 0; i < numPoints * 3; i += 3) {
                colors.array[i] = 1.0;
                colors.array[i + 1] = 1.0;
                colors.array[i + 2] = 1.0;
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


    List<double> _computeBounds(Float32List list) {
        double min = list[0];
        double max = list[0];
        double sum = 0.0;

        for (int i = 0; i < numPoints; i++) {
            double v = list[i];
            min = Math.min(min, v);
            max = Math.max(max, v);
            sum += v;
        }

        double avg = sum / numPoints;

        return [min, max, avg];
    }


    static void _checkValid(Map map) {
        final bool xyz = map.containsKey("positions.x") && map.containsKey("positions.y") && map.containsKey("positions.z");
        assert(xyz);

        final num length = map[map.keys.first].length;
        for (var k in map.keys) {
            assert(map[k].length == length);
        }
    }
}
