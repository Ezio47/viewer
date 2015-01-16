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
    Map<String, PointCloudDimTiles> dimensions = new Map<String, PointCloudDimTiles>();
    int numPoints;


    PointCloud(String this.webpath, String this.displayName) : numPoints = 0;

    void addDimensionData(String name, Float32List data) {
        assert(dimensions[name] != null);

        dimensions[name].add(data);

        if (name == "positions.x") {
            numPoints = dimensions[name].numPoints;
        }
    }

    double minimum(String name) => dimensions[name].minimum;
    double maximum(String name) => dimensions[name].maximum;

    void createDimension(String name) {
        dimensions[name] = new PointCloudDimTiles(name);
    }

    static List<double> _computeLimits(Float32List list) {
        double minimum = list[0];
        double maximum = list[0];

        for (int i = 0; i < list.length; i++) {
            double v = list[i];
            minimum = min(minimum, v);
            maximum = max(maximum, v);
        }

        return [minimum, maximum];
    }

    bool get hasXYZ {
        final bool xyz =
                dimensions.containsKey("positions.x") &&
                dimensions.containsKey("positions.y") &&
                dimensions.containsKey("positions.z");
        return xyz;
    }

    bool get hasColor3 {
        final bool xyz =
                dimensions.containsKey("colors.x") &&
                dimensions.containsKey("colors.y") &&
                dimensions.containsKey("colors.z");
        return xyz;
    }
}


// this isn't really a tile, in that it is bounded by number of points as opposed to geo extents
class PointCloudTile {
    String dimension;
    Float32List data;
    double minimum, maximum;

    PointCloudTile(String dimension, Float32List srcData) : this.dimension = dimension {
        data = PointCloudTile._clone(srcData);

        _computeBounds();
    }

    void _computeBounds() {
        if (data.length == 0) return;

        minimum = data[0];
        maximum = data[0];

        for (int i = 1; i < data.length; i++) {
            double v = data[i];
            minimum = min(minimum, v);
            maximum = max(maximum, v);
        }
    }

    int get numPoints => data.length;

    static Float32List _clone(Float32List src) {
        var dest = new Float32List(src.length);
        for (int i = 0; i < src.length; i++) dest[i] = src[i];
        return dest;
    }
}


// all the tiles for a given dimension
class PointCloudDimTiles {
    String dimension;
    List<PointCloudTile> list;
    double minimum, maximum;
    int numPoints;

    PointCloudDimTiles(String this.dimension)
            : list = new List<PointCloudTile>(),
              numPoints = 0;

    void add(Float32List data) {
        PointCloudTile tile = new PointCloudTile(dimension, data);
        list.add(tile);

        _updateBounds(tile);
        numPoints += tile.numPoints;
    }

    void _updateBounds(PointCloudTile tile) {
        assert(tile != null);
        if (tile.data.length == 0) return;

        if (minimum == null) {
            assert(maximum == null);
            minimum = tile.minimum;
            maximum = tile.maximum;
            return;
        }

        minimum = min(minimum, tile.minimum);
        maximum = max(maximum, tile.maximum);
    }
}
