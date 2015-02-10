// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// this isn't really a tile, in that it is bounded by number of points as opposed to geo extents
class PointCloudTile {
    PointCloud cloud;
    int numPointsInTile;
    int id;
    List<String> dimensionNames;
    Map<String, TypedData> data;
    CartographicBbox bbox;
    CloudShape shape;
    Map<String, double> minimums;
    Map<String, double> maximums;
    int numDims;
    int tileLevel, tileX, tileY;
    int childMask;

    String key;

    PointCloudTile(PointCloud this.cloud, int this.tileLevel, int this.tileX, int this.tileY) {
        key = "$tileLevel $tileX $tileY";

        log("making tile $key");

        dimensionNames = cloud.dimensionNames;

        bbox = new CartographicBbox.empty();
        data = new Map<String, TypedData>();

        numDims = dimensionNames.length;

        minimums = new Map<String, double>();
        maximums = new Map<String, double>();
        dimensionNames.forEach((s) {
            minimums[s] = double.MAX_FINITE;
            maximums[s] = -double.MAX_FINITE;
        });
    }

    void updateShape() {
        var x = data["X"];
        var y = data["Y"];
        var z = data["Z"];

        var rgba = data["rgba"];
        if (rgba == null) return;

        if (shape != null) {
            shape.remove();
        }

        shape = new CloudShape(x, y, z, rgba);
        shape.name = "{pointCloud.webpath}-$id";
    }

    void addData_F64x3(String dim, Float64List xyz) {
        assert(dimensionNames.contains(dim));
        data[dim] = xyz;
    }

    void addData_F64x3_from3(String dim, Float64List xdata, Float64List ydata, Float64List zdata) {
        assert(dimensionNames.contains(dim));

        var xyz = new Float64List(numPointsInTile * 3);
        for (int i = 0; i < numPointsInTile; i++) {
            xyz[i * 3 + 0] = xdata[i];
            xyz[i * 3 + 1] = ydata[i];
            xyz[i * 3 + 2] = zdata[i];
        }

        addData_F64x3(dim, xyz);
    }

    void addData_generic(String dim, List d) {
        assert(dimensionNames.contains(dim));
        TypedData td = d as TypedData;
        assert(d.length == numPointsInTile);
        data[dim] = td;
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

        dimensionNames.forEach((dim) {
            List list = data[dim] as List;
            double lo = double.MAX_FINITE;
            double hi = -double.MAX_FINITE;
            for (int i = 0; i < numPointsInTile; i++) {
                final double v = list[i].toDouble();
                lo = min(lo, v);
                hi = max(hi, v);
            }
            minimums[dim] = lo;
            maximums[dim] = hi;
        });

        bbox.unionWith3(minimums["X"], minimums["Y"], minimums["Z"]);
        bbox.unionWith3(maximums["X"], maximums["Y"], maximums["Z"]);
    }
}
