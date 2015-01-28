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
    CartographicBbox bbox;
    List<String> dimensionNames;
    int numPoints;
    int tileId = 0;
    bool isVisible;

    PointCloud(String this.webpath, String this.displayName, List<String> names)
            : numPoints = 0,
              isVisible = true {

        dimensionNames = new List<String>.from(names);

        bbox = new CartographicBbox.empty();

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

        print("Bounds: $bbox");
    }

    void updateBoundsForTile(PointCloudTile tile) {
        bbox.unionWith(tile.bbox);

        print("Bounds: $bbox");
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
