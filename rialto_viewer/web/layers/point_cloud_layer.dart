// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class PointCloudLayer extends Layer {
    PointCloud cloud;
    PointCloudColorizer _colorizer;
    RiaFormat _ria;
    var comms;

    static const int _pointsPerTile = 1024 * 10;

    Map tileObjects = new Map<String, PointCloudTile>();
    Map tilePrimitives = new Map<String, dynamic>();

    PointCloudLayer(String name, Map map)
            : super(name, map) {
        log("New tiled pointcloud layer: $name .. $server .. $path");
    }

    @override
    Future<bool> load() {
        Completer c = new Completer();

        _ria = new RiaFormat();

        Comms.httpGet(server + path + "/header.json").then((String json) {

            _ria.readHeaderJson(json);

            log(_ria);
            final int pointSize = _ria.pointSizeInBytes;

            // TODO: too conservative? the presence of X,Y,Z should be enough (not array index)
            if (_ria.dimensions[0].name != "X" || _ria.dimensions[1].name != "Y" || _ria.dimensions[2].name != "Z") {
                Hub.error("point cloud does not have required X, Y, Z dimensions");
                c.complete(false);
                return;
            }

            // TODO: does the datatype matter anymore?
            if (_ria.dimensions[0].type != RiaDimension.Double || _ria.dimensions[1].type != RiaDimension.Double || _ria.dimensions[2].type != RiaDimension.Double) {
                Hub.error("point cloud does not have X, Y, Z dimensions as F64 datatype");
                c.complete(false);
                return;
            }

            var dimlist = _ria.dimensionMap.keys.toList();
            dimlist.add("rgba");

            cloud = new PointCloud(path, name, dimlist);

            _hub.cesium.createTileProvider(server + path, _tileCreatorFunc, _tileGetterFunc);

            assert(cloud != null);

            cloud.changeVisibility(isVisible);

            bbox = new CartographicBbox.copy(cloud.bbox);

            _colorizer = new PointCloudColorizer(cloud);

            c.complete(true);
        });

        return c.future;
    }


    PointCloudTile createTheTile(int tileLevel, int tileX, int tileY, double west, double south, double east, double north) {

        var tile = new PointCloudTile(cloud, tileLevel, tileX, tileY, west, south, east, north);

        tileObjects[tile.key] = tile;

        //log("created tile ${tile.key}");

        return tile;
    }

    void loadTheTile(PointCloudTile tile, var buffer) {

        //var ByteBuffer buffer
        ByteData bytes = new ByteData.view(buffer);

        final int pointSize = _ria.pointSizeInBytes;

        final int numBytes = bytes.lengthInBytes;

        // subtract off children mask
        tile.numPointsInTile = (numBytes - 1) ~/ pointSize;
        assert(tile.numPointsInTile * pointSize == (numBytes - 1));

        final int numDims = _ria.dimensions.length;
        List dims = _ria.dimensions;

        // for each dim, add a new data array for this tile to use
        for (int j = 0; j < numDims; j++) {
            RiaDimension dim = dims[j];
            dim.reset(tile.numPointsInTile);
        }

        // read the data into the array inside each RiaDim
        int index = 0;
        for (int i = 0; i < tile.numPointsInTile; i++) {
            for (int j = 0; j < numDims; j++) {
                RiaDimension dim = dims[j];
                dim.setter(bytes, index, i);
                index += dim.sizeInBytes;
            }
        }

        final int childMask = bytes.getUint8(index);
        ++index;

        assert(index == numBytes);

        if (tile.numPointsInTile != 0) {

            // now make the tile point to the RiaDims' array stores
            for (int j = 0; j < numDims; j++) {
                RiaDimension dim = dims[j];
                List list = dim.list;
                tile.addData_generic(dim.name, list);
            }

            // set color data
            tile.addData_U8x4_fromConstant("rgba", 255, 255, 255, 255);
        }

        tile.updateBounds();
        cloud.updateBoundsForTile(tile);

        //log("loaded tile ${tile.key}");
    }


    void renderTheTile(PointCloudTile tile) {

        var p;
        if (tile.numPointsInTile == 0) {
            p = null;
        } else {
            tile.updateShape();
            p = tile.shape.primitive;
        }

        tilePrimitives[tile.key] = p;

        //log("rendered tile ${tile.key}");

        return;
    }

    // called from Js: given a tile key...
    dynamic _tileGetterFunc(int tileLevel, int tileX, int tileY) {
        final key = "$tileLevel $tileX $tileY";
        if (tilePrimitives.containsKey(key)) {
            return tilePrimitives[key];
        }
        return null;
    }

    // called from Js: given a tile key...
    //   - make the tile, if needed
    void _tileCreatorFunc(int tileLevel, int tileX, int tileY, num west, num south, num east, num north, var blob) {
        final key = "$tileLevel $tileX $tileY";

        //log("creator request: $key");

        if (tileObjects.containsKey(key)) {
            // TODO: this shouldn't happen?
            return;
        }

        var tile = createTheTile(tileLevel, tileX, tileY, west.toDouble(), south.toDouble(), east.toDouble(), north.toDouble());
        loadTheTile(tile, blob);
        renderTheTile(tile);
    }

    @override
    void changeVisibility(bool v) {
        cloud.changeVisibility(v);
        isVisible = v;
    }

    Future colorizeAsync(ColorizeLayersData data) {
        return new Future(() {
            _colorizer.ramp = data.ramp;
            _colorizer.dimension = data.dimension;
            _colorizer.colorize();
        });
    }
}
