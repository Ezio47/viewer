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
    Vector3 minimum;
    Vector3 maximum;
    Vector3 len;
    int numPoints;
    int tileId = 0;
    bool isVisible;

    PointCloud(String this.webpath, String this.displayName, List<String> names)
            : numPoints = 0,
              isVisible = true {

        dimensionNames = new List<String>.from(names);

        minimum = new Vector3(double.MAX_FINITE, double.MAX_FINITE, double.MAX_FINITE);
        maximum = new Vector3(-double.MAX_FINITE, -double.MAX_FINITE, -double.MAX_FINITE);
        len = new Vector3(0.0, 0.0, 0.0);

        tiles = new List<PointCloudTile>();
    }

    PointCloudTile createTile(int numPointsInTile) {
        var tile = new PointCloudTile(dimensionNames, numPointsInTile, tileId++);
        tiles.add(tile);

        numPoints += numPointsInTile;

        return tile;
    }

    void updateAllBounds() {

        for (var tile in tiles) {
            updateBoundsForTile(tile);
        }

        print("Bounds: min=${Utils.printv(minimum)} max=${Utils.printv(maximum)} len=${Utils.printv(len)}");
    }

    void updateBoundsForTile(PointCloudTile tile) {
        minimum.x = min(minimum.x, tile.minimum.x);
        maximum.x = max(maximum.x, tile.maximum.x);
        minimum.y = min(minimum.y, tile.minimum.y);
        maximum.y = max(maximum.y, tile.maximum.y);
        minimum.z = min(minimum.z, tile.minimum.z);
        maximum.z = max(maximum.z, tile.maximum.z);

        len = maximum - minimum;

        Hub.root.renderer.forceUpdate();

        print("Bounds: min=${Utils.printv(minimum)} max=${Utils.printv(maximum)} len=${Utils.printv(len)}");
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
