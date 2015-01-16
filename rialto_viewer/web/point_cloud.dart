// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// holds the data once a cloud has been loaded
// data is stored in Float32List arrays, exactly as from the disk (and not in the
// GeometryAttribute renderable format)

class PointCloud {
    static const int TILESIZE = 1024;

    String displayName;
    String webpath;
    Map<String, PointCloudDimTiles> dimensions = new Map<String, PointCloudDimTiles>();
    Map<String, double> minimum = new Map<String, double>();
    Map<String, double> maximum = new Map<String, double>();
    int numPoints;


    PointCloud(String this.webpath, String this.displayName, int this.numPoints);

    void addDimensionData(String name, Float32List data) {
        assert(dimensions[name] != null);
        assert(data.length <= PointCloud.TILESIZE);

        dimensions[name].add(data);

        minimum[name] = dimensions[name].minimum;
        maximum[name] = dimensions[name].maximum;
    }

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

    int get numTiles => (numPoints.toDouble() / PointCloud.TILESIZE.toDouble()).ceil();
    int get tileSize => PointCloud.TILESIZE;
    int get tileSizeRemainder =>
            (numPoints % PointCloud.TILESIZE == 0) ? PointCloud.TILESIZE : (numPoints % PointCloud.TILESIZE);
}


// this isn't really a tile, in that it is bounded by number of points as opposed to geo extents
class PointCloudTile {
    String dimension;
    Float32List data;
    double minimum, maximum;

    PointCloudTile(String dimension, Float32List srcData) : this.dimension = dimension {
        data = PointCloudTile._clone(srcData);

        assert(data.length <= PointCloud.TILESIZE);

        _computeBounds();
    }

    void _computeBounds() {
        minimum = data[0];
        maximum = data[0];

        for (int i = 0; i < data.length; i++) {
            double v = data[i];
            minimum = min(minimum, v);
            maximum = max(maximum, v);
        }
    }

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

    PointCloudDimTiles(String this.dimension) {
        list = new List<PointCloudTile>();
    }

    void add(Float32List data) {
        PointCloudTile tile = new PointCloudTile(dimension, data);
        list.add(tile);

        _updateBounds(tile);
    }

    void _updateBounds(PointCloudTile tile) {
        assert(tile != null);

        if (minimum == null) {
            assert(maximum == null);
            minimum = tile.minimum;
            maximum = tile.maximum;
        } else {
            minimum = min(minimum, tile.minimum);
            maximum = max(minimum, tile.maximum);
        }
    }
}
