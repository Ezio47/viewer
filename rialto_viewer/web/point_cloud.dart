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
    List<PointCloudTile> tiles;
    List<String> dimensionNames;
    Map<String, double> minimum;
    Map<String, double> maximum;
    int numPoints;
    int tileId = 0;
    List<CloudShape> _cloudShapes = new List<CloudShape>();
    bool visible;
    Vector3 vmin, vmax, vlen;

    PointCloud(String this.webpath, String this.displayName, List<String> names)
            : numPoints = 0,
              visible = true {

        dimensionNames = new List<String>.from(names);

        minimum = new Map<String, double>();
        maximum = new Map<String, double>();

        tiles = new List<PointCloudTile>();

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

    PointCloudTile createTile(int numPointsInTile) {
        var tile = new PointCloudTile(dimensionNames, numPointsInTile, tileId++);
        tiles.add(tile);
        return tile;
    }

    void updateBounds() {
        numPoints = 0;
        for (var tile in tiles) {
            for (var dimensionName in dimensionNames) {
                if (dimensionName == "xyz") {
                    minimum["x"] = min(minimum["x"], tile.minimum["x"]);
                    maximum["x"] = max(maximum["x"], tile.maximum["x"]);
                    minimum["y"] = min(minimum["y"], tile.minimum["y"]);
                    maximum["y"] = max(maximum["y"], tile.maximum["y"]);
                    minimum["z"] = min(minimum["z"], tile.minimum["z"]);
                    maximum["z"] = max(maximum["z"], tile.maximum["z"]);
                } else if (dimensionName == "rgba") {
                    minimum["r"] = min(minimum["r"], tile.minimum["r"]);
                    maximum["r"] = max(maximum["r"], tile.maximum["r"]);
                    minimum["g"] = min(minimum["g"], tile.minimum["g"]);
                    maximum["g"] = max(maximum["g"], tile.maximum["g"]);
                    minimum["b"] = min(minimum["b"], tile.minimum["b"]);
                    maximum["b"] = max(maximum["b"], tile.maximum["b"]);
                    minimum["a"] = min(minimum["a"], tile.minimum["a"]);
                    maximum["a"] = max(maximum["a"], tile.maximum["a"]);
                } else {
                    minimum[dimensionName] = min(minimum[dimensionName], tile.minimum[dimensionName]);
                    maximum[dimensionName] = max(maximum[dimensionName], tile.maximum[dimensionName]);
                }
            }
            numPoints += tile.numPointsInTile;
        }

        vmin = new Vector3(minimum["x"], minimum["y"], minimum["z"]);
        vmax = new Vector3(maximum["x"], maximum["y"], maximum["z"]);
        vlen = vmax - vmin;

        print("Bounds: min=${Utils.printv(vmin)} max=${Utils.printv(vmax)} len=${Utils.printv(vlen)}");
    }


    List<CloudShape> buildParticleSystem() {
        for (PointCloudTile tile in tiles) {

            var positions = tile.data["xyz"];
            var colors = tile.data["rgba"];
            assert(positions != null);
            assert(colors != null);

            var cloudShape = new CloudShape(positions, colors);
            cloudShape.name = "{pointCloud.webpath}-${tile.id}";
            _cloudShapes.add(cloudShape);
        }
        return _cloudShapes;
    }

    void colorize(Colorizer colorizer) {
        colorizer.run(this);
    }

    bool get hasXyz {
        return dimensionNames.contains("xyz");
    }

    bool get hasRgba {
        return dimensionNames.contains("rgba");
    }
}


// this isn't really a tile, in that it is bounded by number of points as opposed to geo extents
class PointCloudTile {
    int numPointsInTile;
    int id;
    List<String> dimensionNames;
    Map<String, Float32List> data;
    Map<String, double> minimum;
    Map<String, double> maximum;

    PointCloudTile(List<String> this.dimensionNames, int this.numPointsInTile, int this.id) {
        log("making tile $id with $numPointsInTile");

        minimum = new Map<String, double>();
        maximum = new Map<String, double>();
        data = new Map<String, Float32List>();

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

    void addData_F32x3(String dim, Float32List xdata, Float32List ydata, Float32List zdata) {
        assert(dimensionNames.contains(dim));

        var xyz = new Float32List(numPointsInTile * 3);
        for (int i = 0; i < numPointsInTile; i++) {
            xyz[i * 3 + 0] = xdata[i];
            xyz[i * 3 + 1] = ydata[i];
            xyz[i * 3 + 2] = zdata[i];
        }

        data[dim] = xyz;
        _updateBounds(dim);
    }

    void addData_F32x4(String dim, Float32List xdata, Float32List ydata, Float32List zdata, Float32List wdata) {
        assert(dimensionNames.contains(dim));

        var xyzw = new Float32List(numPointsInTile * 4);
        for (int i = 0; i < numPointsInTile; i++) {
            xyzw[i * 4 + 0] = xdata[i];
            xyzw[i * 4 + 1] = ydata[i];
            xyzw[i * 4 + 2] = zdata[i];
            xyzw[i * 4 + 3] = wdata[i];
        }

        data[dim] = xyzw;
        _updateBounds(dim);
    }

    void _updateBounds(String dimensionName) {
        if (dimensionName == "xyz") {
            for (int i = 0; i < numPointsInTile; i++) {
                double x = data["xyz"][i * 3];
                double y = data["xyz"][i * 3 + 1];
                double z = data["xyz"][i * 3 + 2];
                minimum["x"] = min(minimum["x"], x);
                maximum["x"] = max(maximum["x"], x);
                minimum["y"] = min(minimum["y"], y);
                maximum["y"] = max(maximum["y"], y);
                minimum["z"] = min(minimum["z"], z);
                maximum["z"] = max(maximum["z"], z);
            }
        } else if (dimensionName == "rgba") {
            for (int i = 0; i < numPointsInTile; i++) {
                double r = data["rgba"][i * 4];
                double g = data["rgba"][i * 4 + 1];
                double b = data["rgba"][i * 4 + 2];
                double a = data["rgba"][i * 4 + 3];
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
            for (int i = 0; i < numPointsInTile; i++) {
                double v = data[dimensionName][i];
                minimum[dimensionName] = min(minimum[dimensionName], v);
                maximum[dimensionName] = max(maximum[dimensionName], v);
            }
        }
    }

    //static Float32List _clone(Float32List src) {
    //    var dest = new Float32List(src.length);
    //    for (int i = 0; i < src.length; i++) dest[i] = src[i];
    //    return dest;
    //}
}
