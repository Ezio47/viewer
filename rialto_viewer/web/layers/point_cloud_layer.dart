// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class TiledPointCloudLayer extends Layer {
    PointCloud cloud;
    PointCloudColorizer _colorizer;
    RiaFormat _ria;

    static const int _pointsPerTile = 1024 * 10;

    TiledPointCloudLayer(String name, Map map)
            : super(name, map) {
        log("New tiled pointcloud layer: $name .. $server .. $path");
    }

    @override
    Future<bool> load() {
        Completer c = new Completer();

        var whenReady = () {
            assert(cloud != null);

            cloud.changeVisibility(isVisible);

            bbox = new CartographicBbox.copy(cloud.bbox);

            _colorizer = new PointCloudColorizer(cloud);

            c.complete(true);
        };


        var comms = new WebSocketReader(server);

        _ria = new RiaFormat();

        comms.readAllText(path + "/header.json").then((String json) {

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
            if (_ria.dimensions[0].type != RiaDimension.Double ||
                    _ria.dimensions[1].type != RiaDimension.Double ||
                    _ria.dimensions[2].type != RiaDimension.Double) {
                Hub.error("point cloud does not have X, Y, Z dimensions as F64 datatype");
                c.complete(false);
                return;
            }

            var dimlist = _ria.dimensionMap.keys.toList();
            dimlist.add("rgba");

            cloud = new PointCloud(path, name, dimlist);

            // bring in the two root tiles
            String tilePath = "$path/0/0/0.ria";
            comms.readAll(tilePath).then((ByteData bytes) {
                var tile = _createTile(bytes, 0, 0, 0);
                loadedTiles["0 0 0"] = tile.shape.primitive;
                _setChildren(tile);
            });

            tilePath = "$path/0/1/0.ria";
            comms.readAll(tilePath).then((ByteData bytes) {
                var tile = _createTile(bytes, 0, 1, 0);
                loadedTiles["0 1 0"] = tile.shape.primitive;
                _setChildren(tile);
            });

            _hub.cesium.createTileProvider(_tileGetterHandler);

            //  final int numBytes = pointSize * _pointsPerTile;
            //comms.readChunked(path, numBytes, _createTile).then((bool ok) {
            //  if (!ok) {
            //    c.complete(false);
            //  return;
            //}
            whenReady();
            //});
        });

        return c.future;
    }


    Map loadedTiles = new Map();

    dynamic _tileGetterHandler(int tileLevel, int tileX, int tileY, num iwest, num isouth, num ieast, num inorth) {

        double west = iwest.toDouble();
        double south = isouth.toDouble();
        double east = ieast.toDouble();
        double north = inorth.toDouble();

        log("$tileLevel $tileX $tileY - $west $south $east $north");
        var key = "$tileLevel $tileX $tileY";

        if (loadedTiles.containsKey(key)) {
            return loadedTiles[key];
        }

        north = north.toDouble();
        south = south.toDouble();
        east = east.toDouble();
        west = west.toDouble();

        var s = south + (north - south) / 2.0;
        var w = west + (east - west) / 2.0;

        var center = new Cartographic3(w, s, 0.0);
        var point = new Cartographic3(west, south, 0.0);
        var p = _hub.cesium.createRectangle(point, center, 0.0, 0.0, 1.0);


        var comms = new WebSocketReader(server);


        String tilePath = "$path/$tileLevel/$tileX/$tileY.ria";

        comms.readAll(tilePath).then((ByteData bytes) {
            var tile = _createTile(bytes, tileLevel, tileX, tileY);
            loadedTiles[key] = tile.shape.primitive;

            _setChildren(tile);
        });

        loadedTiles[key] = p;

        return p;
    }

    PointCloudTile _createTile(ByteData buf, int level, int tileX, int tileY) {
        final int pointSize = _ria.pointSizeInBytes;

        final int numBytes = buf.lengthInBytes;

        // subtract off children mask
        int numPointsInTile = (numBytes - 1) ~/ pointSize;
        assert(numPointsInTile * pointSize == (numBytes - 1));

        final int numDims = _ria.dimensions.length;
        List dims = _ria.dimensions;

        ByteData bytes = buf;

        // for each dim, add a new data array for this tile to use
        for (int j = 0; j < numDims; j++) {
            RiaDimension dim = dims[j];
            dim.reset(numPointsInTile);
        }

        // read the data into the array inside each RiaDim
        int index = 0;
        for (int i = 0; i < numPointsInTile; i++) {
            for (int j = 0; j < numDims; j++) {
                RiaDimension dim = dims[j];
                dim.setter(bytes, index, i);
                index += dim.sizeInBytes;
            }
        }

        final int childMask = bytes.getUint8(index);
        ++index;
        assert(index == numBytes);

        var tile = cloud.createTile(numPointsInTile, level, tileX, tileY, childMask);

        // now make the tile point to the RiaDims' array stores
        for (int j = 0; j < numDims; j++) {
            RiaDimension dim = dims[j];
            List list = dim.list;
            tile.addData_generic(dim.name, list);
        }

        // set color data
        tile.addData_U8x4_fromConstant("rgba", 255, 255, 255, 255);

        tile.updateBounds();
        tile.updateShape();
        cloud.updateBoundsForTile(tile);

        return tile;
    }

    void _setChildren(PointCloudTile tile) {
        var swKey = "${tile.tileLevel+1} ${tile.tileX*2} ${tile.tileY*2}";
        var nwKey = "${tile.tileLevel+1} ${tile.tileX*2+1} ${tile.tileY*2}";
        var seKey = "${tile.tileLevel+1} ${tile.tileX*2} ${tile.tileY*2+1}";
        var neKey = "${tile.tileLevel+1} ${tile.tileX*2+1} ${tile.tileY*2+1}";

        bool swPresent = (tile.childMask & 1 == 1);
        bool sePresent = (tile.childMask & 2 == 2);
        bool nePresent = (tile.childMask & 4 == 4);
        bool nwPresent = (tile.childMask & 8 == 8);

        if (!swPresent) loadedTiles[swKey] = null;
        if (!sePresent) loadedTiles[seKey] = null;
        if (!nePresent) loadedTiles[neKey] = null;
        if (!nwPresent) loadedTiles[nwKey] = null;
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



class PointCloudLayer extends Layer {
    PointCloud cloud;
    PointCloudColorizer _colorizer;
    RiaFormat _ria;

    static const int _pointsPerTile = 1024 * 10;

    PointCloudLayer(String name, Map map)
            : super(name, map) {
        log("New pointcloud layer: $name .. $server .. $path");
    }

    @override
    Future<bool> load() {
        Completer c = new Completer();

        var whenReady = () {
            assert(cloud != null);

            cloud.changeVisibility(isVisible);

            bbox = new CartographicBbox.copy(cloud.bbox);

            _colorizer = new PointCloudColorizer(cloud);

            c.complete(true);
        };

        if (server == "http://www.example.com") {
            cloud = PointCloudGenerator.generate(path, name);
            whenReady();
        } else {

            var comms = new WebSocketReader(server);

            _ria = new RiaFormat();

            comms.readAll(path + "hdr").then((ByteData buf) {

                _ria.readHeader(buf);
                log(_ria);
                final int pointSize = _ria.pointSizeInBytes;

                // TODO: too conservative? the presence of X,Y,Z should be enough (not array index)
                if (_ria.dimensions[0].name != "X" ||
                        _ria.dimensions[1].name != "Y" ||
                        _ria.dimensions[2].name != "Z") {
                    Hub.error("point cloud does not have required X, Y, Z dimensions");
                    c.complete(false);
                    return;
                }

                // TODO: does the datatype matter anymore?
                if (_ria.dimensions[0].type != RiaDimension.Double ||
                        _ria.dimensions[1].type != RiaDimension.Double ||
                        _ria.dimensions[2].type != RiaDimension.Double) {
                    Hub.error("point cloud does not have X, Y, Z dimensions as F64 datatype");
                    c.complete(false);
                    return;
                }

                var dimlist = _ria.dimensionMap.keys.toList();
                dimlist.add("rgba");

                cloud = new PointCloud(path, name, dimlist);

                final int numBytes = pointSize * _pointsPerTile;
                comms.readChunked(path, numBytes, _createTile).then((bool ok) {
                    if (!ok) {
                        c.complete(false);
                        return;
                    }
                    whenReady();
                });
            });
        }

        return c.future;
    }

    void _createTile(ByteData buf) {
        final int pointSize = _ria.pointSizeInBytes;

        final int numBytes = buf.lengthInBytes;

        int numPointsInTile = numBytes ~/ pointSize;
        assert(numPointsInTile * pointSize == numBytes);

        final int numDims = _ria.dimensions.length;
        List dims = _ria.dimensions;

        ByteData bytes = buf;

        // for each dim, add a new data array for this tile to use
        for (int j = 0; j < numDims; j++) {
            RiaDimension dim = dims[j];
            dim.reset(numPointsInTile);
        }

        // read the data into the array inside each RiaDim
        int index = 0;
        for (int i = 0; i < numPointsInTile; i++) {
            for (int j = 0; j < numDims; j++) {
                RiaDimension dim = dims[j];
                dim.setter(bytes, index, i);
                index += dim.sizeInBytes;
            }
        }

        var tile = cloud.createTile(numPointsInTile);

        // now make the tile point to the RiaDims' array stores
        for (int j = 0; j < numDims; j++) {
            RiaDimension dim = dims[j];
            List list = dim.list;
            tile.addData_generic(dim.name, list);
        }

        // set color data
        tile.addData_U8x4_fromConstant("rgba", 255, 255, 255, 255);

        tile.updateBounds();
        tile.updateShape();
        cloud.updateBoundsForTile(tile);
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
