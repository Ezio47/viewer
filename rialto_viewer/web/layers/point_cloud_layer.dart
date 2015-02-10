// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class TiledPointCloudLayer extends Layer {
    PointCloud cloud;
    PointCloudColorizer _colorizer;
    RiaFormat _ria;
    var comms;

    static const int _pointsPerTile = 1024 * 10;

    static const int CREATABLE = 1;
    static const int CREATED = 2;
    static const int LOADED = 3;
    static const int RENDERED = 4;
    static const int NODATA = 5;

    Map tileState = new Map<String, int>();
    Map tilePrimitives = new Map<String, dynamic>();

    TiledPointCloudLayer(String name, Map map)
            : super(name, map) {
        log("New tiled pointcloud layer: $name .. $server .. $path");
    }

    @override
    Future<bool> load() {
        Completer c = new Completer();

        comms = new WebSocketReader(server);

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

            tileState["0 0 0"] = CREATABLE;
            tileState["0 1 0"] = CREATABLE;

            _hub.cesium.createTileProvider(_tileGetterHandler);

            assert(cloud != null);

            cloud.changeVisibility(isVisible);

            bbox = new CartographicBbox.copy(cloud.bbox);

            _colorizer = new PointCloudColorizer(cloud);

            c.complete(true);
        });

        return c.future;
    }


    Future<PointCloudTile> createTheTile(int tileLevel, int tileX, int tileY) {

        var c = new Completer<PointCloudTile>();

        var tile = new PointCloudTile(cloud, tileLevel, tileX, tileY);

        tileState[tile.key] = CREATED;

        c.complete(tile);

        log("created tile ${tile.key}");

        return c.future;
    }

    Future<bool> loadTheTile(PointCloudTile tile) {
        var c = new Completer<bool>();

        var tilePath = "$path/${tile.tileLevel}/${tile.tileX}/${tile.tileY}.ria";

        comms.readAll(tilePath).then((ByteData bytes) {

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
            setTheChildren(tile, childMask);
            ++index;
            assert(index == numBytes);

            if (tile.numPointsInTile == 0) {
                return null;
            }

            // now make the tile point to the RiaDims' array stores
            for (int j = 0; j < numDims; j++) {
                RiaDimension dim = dims[j];
                List list = dim.list;
                tile.addData_generic(dim.name, list);
            }

            // set color data
            tile.addData_U8x4_fromConstant("rgba", 255, 255, 255, 255);

            tile.updateBounds();
            cloud.updateBoundsForTile(tile);

            tileState[tile.key] = LOADED;

            log("loaded tile ${tile.key}");

            c.complete(true);
        });

        return c.future;
    }

    void setTheChildren(PointCloudTile tile, int mask) {
        final level = tile.tileLevel;
        final x = tile.tileX;
        final y = tile.tileY;

        var swKey = "${level+1} ${x*2} ${y*2}";
        var nwKey = "${level+1} ${x*2+1} ${y*2}";
        var seKey = "${level+1} ${x*2} ${y*2+1}";
        var neKey = "${level+1} ${x*2+1} ${y*2+1}";

        bool swPresent = (mask & 1 == 1);
        bool sePresent = (mask & 2 == 2);
        bool nePresent = (mask & 4 == 4);
        bool nwPresent = (mask & 8 == 8);

        tileState[swKey] = swPresent ? CREATABLE : NODATA;
        tileState[seKey] = sePresent ? CREATABLE : NODATA;
        tileState[neKey] = nePresent ? CREATABLE : NODATA;
        tileState[nwKey] = nwPresent ? CREATABLE : NODATA;
    }


    Future<dynamic> renderTheTile(PointCloudTile tile) {
        var c = new Completer<dynamic>();

        tile.updateShape();

        var p = tile.shape.primitive;

        c.complete(p);

        tileState[tile.key] = RENDERED;
        tilePrimitives[tile.key] = p;

        log("rendered tile ${tile.key}");

        return c.future;
    }

    // called from Js: given a tile key...
    //   - make the tile, if needed
    //   - make a primitive and return it
    void _tileGetterHandler(int tileLevel, int tileX, int tileY) {
        final key = "$tileLevel $tileX $tileY";

        log("getter request: $key");

        bool loadme = false;

        ///////////context.callMethod("bouncer", [cb, p]);

        if (!tileState.containsKey(key)) {
            // ????
            return;
        }

        assert(tileState.containsKey(key));
        final int state = tileState[key];

        if (state == CREATABLE) {
            createTheTile(tileLevel, tileX, tileY).then((tile) {
                 loadTheTile(tile).then((ok) {
                    renderTheTile(tile).then((p) {
                        //
                    });
                 });
             });
            return;
        }

        if (state == CREATED) {
            return;
        }

        if (state == LOADED) {
            return;
        }
        if (state == RENDERED) {
            var p = tilePrimitives[key];
            assert(p != null);
            return;
        }

        if (state == NODATA) {
            // do nothing
            return;
        }

        assert(false);
    }

    dynamic renderTheRect(PointCloudTile tile)
    {
        /*
        north = north.toDouble();
        south = south.toDouble();
        east = east.toDouble();
        west = west.toDouble();

        var s = south + (north - south) / 2.0;
        var w = west + (east - west) / 2.0;

        var center = new Cartographic3(w, s, 0.0);
        var point = new Cartographic3(west, south, 0.0);
        var p = _hub.cesium.createRectangle(point, center, 0.0, 0.0, 1.0);
        return p;
         */
        return null;
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
