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
    Map<String, double> minimums;
    Map<String, double> maximums;

    PointCloud(String this.webpath, String this.displayName)
            : numPoints = 0 {

//        dimensionNames = new List<String>.from(names);

        bbox = new CartographicBbox.empty();

//        minimums = new Map<String, double>();
//        maximums = new Map<String, double>();
//        dimensionNames.forEach((s) {
//            minimums[s] = double.MAX_FINITE;
//            maximums[s] = -double.MAX_FINITE;
//        });
    }

    void changeVisibility(bool v) {
//        for (var tile in tiles) {
//            tile.shape.isVisible = v;
//        }
    }

    void updateAllBounds() {

//        for (var tile in tiles) {
  //          updateBoundsForTile(tile);
    //    }

        log("Bounds: $bbox");
    }

    void updateBoundsForTile(PointCloudTile tile) {

//        dimensionNames.forEach((dim) {
  //          minimums[dim] = min(minimums[dim], tile.minimums[dim]);
    //        maximums[dim] = max(maximums[dim], tile.maximums[dim]);
      //  });

        //bbox.unionWith(tile.bbox);

        log("Bounds: $bbox");
    }
}
