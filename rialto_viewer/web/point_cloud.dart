// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// holds the data once a cloud has been loaded
// data is stored in Float32List arrays, exactly as from the disk (and not in the
// GeometryAttribute renderable format)

class PointCloud {
    String displayName;
    String webpath;
    var dimensions = new Map<String, Float32List>();
    var minimum = new Map<String, double>();
    var maximum = new Map<String, double>();
    var average = new Map<String, double>();
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
        minimum[name] = list[0];
        maximum[name] = list[1];
        average[name] = list[2];
    }

    void createDimension(String name, Float32List data) {
        if (dimensions.keys.length == 0) {
            numPoints = data.length;
        } else {
            if (data.length != numPoints) throw new RialtoArgumentError("all dimensions must be of same length");
        }

        dimensions[name] = data;

        var list = _computeLimits(data);
        minimum[name] = list[0];
        maximum[name] = list[1];
        average[name] = list[2];
    }

    void createDimensions(Map<String, Float32List> map) {
        map.forEach((k, v) => createDimension(k, v));
    }

    static List<double> _computeLimits(Float32List list) {
        double minimum = list[0];
        double maximum = list[0];
        double sum = 0.0;

        for (int i = 0; i < list.length; i++) {
            double v = list[i];
            minimum = min(minimum, v);
            maximum = max(maximum, v);
            sum += v;
        }

        double average = sum / list.length;

        return [minimum, maximum, average];
    }

    bool get hasXYZ {
        final bool xyz = dimensions.containsKey("positions.x") && dimensions.containsKey("positions.y") && dimensions.containsKey("positions.z");
        return xyz;
    }

    bool get hasColor3 {
        final bool xyz = dimensions.containsKey("colors.x") && dimensions.containsKey("colors.y") && dimensions.containsKey("colors.z");
        return xyz;
    }
}
