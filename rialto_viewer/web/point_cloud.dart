library point_cloud;

import 'dart:core';
import 'dart:math' as Math;
import 'dart:typed_data';

import 'rialto_exceptions.dart';


// holds the data once a cloud has been loaded
// data is stored in Float32List arrays, exactly as from the disk (and not in the
// GeometryAttribute renderable format)

class PointCloud {
    String displayName;
    String webpath;
    var dimensions = new Map<String, Float32List>();
    var min = new Map<String, double>();
    var max = new Map<String, double>();
    var avg = new Map<String, double>();
    int numPoints;


    PointCloud(String this.webpath, String this.displayName);

    void addToDimension(String name, Float32List data) {
        // how to enforce this?
        //// throw new RialtoArgumentError("all dimensions must be of same length");

        Float32List oldData = dimensions[name];

        dimensions[name] = new Float32List(oldData.length + data.length);
        int i = 0;
        for ( ; i < oldData.length; i++) {
            dimensions[name][i] = oldData[i];
        }
        for ( ; i < oldData.length + data.length; i++) {
            dimensions[name][i] = data[i];
        }

        var list = _computeLimits(data);
        min[name] = list[0];
        max[name] = list[1];
        avg[name] = list[2];
    }

    void createDimension(String name, Float32List data) {
        if (dimensions.keys.length == 0) {
            numPoints = data.length;
        } else {
            if (data.length != numPoints) throw new RialtoArgumentError("all dimensions must be of same length");
        }

        dimensions[name] = data;

        var list = _computeLimits(data);
        min[name] = list[0];
        max[name] = list[1];
        avg[name] = list[2];
    }

    void createDimensions(Map<String, Float32List> map) {
        map.forEach((k, v) => createDimension(k, v));
    }

    static List<double> _computeLimits(Float32List list) {
        double min = list[0];
        double max = list[0];
        double sum = 0.0;

        for (int i = 0; i < list.length; i++) {
            double v = list[i];
            min = Math.min(min, v);
            max = Math.max(max, v);
            sum += v;
        }

        double avg = sum / list.length;

        return [min, max, avg];
    }

    bool get hasXYZ {
        final bool xyz =
                dimensions.containsKey("positions.x") &&
                dimensions.containsKey("positions.y") &&
                dimensions.containsKey("positions.z");
        return xyz;
    }

    bool get hasColor3 {
        final bool xyz =
                dimensions.containsKey("colors.x") &&
                dimensions.containsKey("colors.y") &&
                dimensions.containsKey("colors.z");
        return xyz;
    }
}
