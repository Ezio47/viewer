// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// this isn't really a tile, in that it is bounded by number of points as opposed to geo extents
class PointCloudTile {
    int numPointsInTile;
    int id;
    List<String> dimensionNames;
    Map<String, TypedData> data;
    Map<String, double> minimum;
    Map<String, double> maximum;
    CloudShape shape;

    PointCloudTile(List<String> this.dimensionNames, int this.numPointsInTile, int this.id) {
        log("making tile $id with $numPointsInTile");

        minimum = new Map<String, double>();
        maximum = new Map<String, double>();
        data = new Map<String, TypedData>();

        dimensionNames.forEach((dimensionName) {
            if (dimensionName == "xyz") {
                minimum["x"] = double.MAX_FINITE;
                maximum["x"] = -double.MAX_FINITE;
                minimum["y"] = double.MAX_FINITE;
                maximum["y"] = -double.MAX_FINITE;
                minimum["z"] = double.MAX_FINITE;
                maximum["z"] = -double.MAX_FINITE;
            } else if (dimensionName == "rgba") {
                minimum["r"] = double.MAX_FINITE;
                maximum["r"] = -double.MAX_FINITE;
                minimum["g"] = double.MAX_FINITE;
                maximum["g"] = -double.MAX_FINITE;
                minimum["b"] = double.MAX_FINITE;
                maximum["b"] = -double.MAX_FINITE;
                minimum["a"] = double.MAX_FINITE;
                maximum["a"] = -double.MAX_FINITE;
            } else {
                minimum[dimensionName] = double.MAX_FINITE;
                maximum[dimensionName] = -double.MAX_FINITE;
            }
        });
    }

    void updateShape() {
        var xyz = data["xyz"];
        if (xyz == null) return;

        var rgba = data["rgba"];
        if (rgba == null) return;

        if (shape != null) {
            shape.remove();
        }

        shape = new CloudShape(xyz, rgba);
        shape.name = "{pointCloud.webpath}-$id";
    }

    void addData_F32x3(String dim, Float32List xyz) {
        assert(dimensionNames.contains(dim));
        data[dim] = xyz;
    }

    void addData_F32x3_from3(String dim, Float32List xdata, Float32List ydata, Float32List zdata) {
        assert(dimensionNames.contains(dim));

        var xyz = new Float32List(numPointsInTile * 3);
        for (int i = 0; i < numPointsInTile; i++) {
            xyz[i * 3 + 0] = xdata[i];
            xyz[i * 3 + 1] = ydata[i];
            xyz[i * 3 + 2] = zdata[i];
        }

        addData_F32x3(dim, xyz);
    }

    void addData_U8x4(String dim, Uint8List xyzw) {
        assert(dimensionNames.contains(dim));
        data[dim] = xyzw;
    }

    void addData_U8x4_from4(String dim, Uint8List xdata, Uint8List ydata, Uint8List zdata, Uint8List wdata) {
        assert(dimensionNames.contains(dim));

        var xyzw = new Uint8List(numPointsInTile * 4);
        for (int i = 0; i < numPointsInTile; i++) {
            xyzw[i * 4 + 0] = xdata[i];
            xyzw[i * 4 + 1] = ydata[i];
            xyzw[i * 4 + 2] = zdata[i];
            xyzw[i * 4 + 3] = wdata[i];
        }

        addData_U8x4(dim, xyzw);
    }

    void addData_U8x4_fromConstant(String dim, int x, int y, int z, int w) {
        assert(dimensionNames.contains(dim));

        var xyzw = new Uint8List(numPointsInTile * 4);
        for (int i = 0; i < numPointsInTile; i++) {
            xyzw[i * 4 + 0] = x;
            xyzw[i * 4 + 1] = y;
            xyzw[i * 4 + 2] = z;
            xyzw[i * 4 + 3] = w;
        }

        addData_U8x4(dim, xyzw);
    }

    void updateBounds() {
        for (var dimensionName in dimensionNames) {
            if (dimensionName == "xyz") {
                assert(data["xyz"] is Float32List);
                Float32List d = data["xyz"];
                for (int i = 0; i < numPointsInTile; i++) {
                    double x = d[i * 3];
                    double y = d[i * 3 + 1];
                    double z = d[i * 3 + 2];
                    minimum["x"] = min(minimum["x"], x);
                    maximum["x"] = max(maximum["x"], x);
                    minimum["y"] = min(minimum["y"], y);
                    maximum["y"] = max(maximum["y"], y);
                    minimum["z"] = min(minimum["z"], z);
                    maximum["z"] = max(maximum["z"], z);
                }
            } else if (dimensionName == "rgba") {
                assert(data["rgba"] is Uint8List);
                Uint8List d = data["rgba"];
                for (int i = 0; i < numPointsInTile; i++) {
                    double r = d[i * 4].toDouble();
                    double g = d[i * 4 + 1].toDouble();
                    double b = d[i * 4 + 2].toDouble();
                    double a = d[i * 4 + 3].toDouble();
                    minimum["r"] = min(minimum["r"], r);
                    maximum["r"] = max(maximum["r"], r);
                    minimum["g"] = min(minimum["g"], g);
                    maximum["g"] = max(maximum["g"], g);
                    minimum["b"] = min(minimum["b"], b);
                    maximum["b"] = max(maximum["b"], b);
                    minimum["a"] = min(minimum["a"], a);
                    maximum["a"] = max(maximum["a"], a);
                }
            } else {
                assert(data[dimensionName] is Float32List);
                Float32List d = data[dimensionName];
                for (int i = 0; i < numPointsInTile; i++) {
                    double v = d[i];
                    minimum[dimensionName] = min(minimum[dimensionName], v);
                    maximum[dimensionName] = max(maximum[dimensionName], v);
                }
            }
        }
    }
}
