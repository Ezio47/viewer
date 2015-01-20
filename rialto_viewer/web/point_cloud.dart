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
    bool isVisible;
    Vector3 vmin, vmax, vlen;

    PointCloud(String this.webpath, String this.displayName, List<String> names)
            : numPoints = 0,
              isVisible = true {

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
