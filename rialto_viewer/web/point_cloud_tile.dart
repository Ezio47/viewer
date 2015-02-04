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

    PointCloudTile(PointCloud this.cloud, List<String> this.dimensionNames, int this.numPointsInTile, int this.id) {
        //log("making tile $id with $numPointsInTile");
        bbox = new CartographicBbox.empty();
        data = new Map<String, TypedData>();
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
        assert(data["xyz"] is Float64List);
        Float64List d = data["xyz"];
        for (int i = 0; i < numPointsInTile; i++) {
            double x = d[i * 3];
            double y = d[i * 3 + 1];
            double z = d[i * 3 + 2];
            bbox.unionWith3(x, y, z);
        }
    }
}
