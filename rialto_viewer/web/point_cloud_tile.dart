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
    Vector3 minimum;
    Vector3 maximum;
    CloudShape shape;

    PointCloudTile(List<String> this.dimensionNames, int this.numPointsInTile, int this.id) {
        log("making tile $id with $numPointsInTile");

        minimum = new Vector3(double.MAX_FINITE, double.MAX_FINITE, double.MAX_FINITE);
        maximum = new Vector3(-double.MAX_FINITE, -double.MAX_FINITE, -double.MAX_FINITE);
        data = new Map<String, TypedData>();
    }

    void updateShape() {
        var t0 = new DateTime.now().millisecondsSinceEpoch;
        var xyz = data["xyz"];
        if (xyz == null) return;

        var rgba = data["rgba"];
        if (rgba == null) return;

        if (shape != null) {
            shape.remove();
        }
        var t1 = new DateTime.now().millisecondsSinceEpoch;

        shape = new CloudShape(xyz, rgba);
        shape.name = "{pointCloud.webpath}-$id";
        var t2 = new DateTime.now().millisecondsSinceEpoch;
        log("${t2-t1} ${t1-t0}");
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
        assert(data["xyz"] is Float32List);
        Float32List d = data["xyz"];
        for (int i = 0; i < numPointsInTile; i++) {
            double x = d[i * 3];
            double y = d[i * 3 + 1];
            double z = d[i * 3 + 2];
            minimum.x = min(minimum.x, x);
            maximum.x = max(maximum.x, x);
            minimum.y = min(minimum.y, y);
            maximum.y = max(maximum.y, y);
            minimum.z = min(minimum.z, z);
            maximum.z = max(maximum.z, z);
        }
    }
}
