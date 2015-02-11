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

    static const int CREATABLE = 1;
    static const int CREATED = 2;
    static const int LOADED = 3;
    static const int RENDERED = 4;
    static const int NODATA = 5;

    Map tileState = new Map<String, int>();
    Map tileObjects = new Map<String, PointCloudTile>();
    Map tilePrimitives = new Map<String, dynamic>();

    PointCloudLayer(String name, Map map)
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
            if (_ria.dimensions[0].type != RiaDimension.Double || _ria.dimensions[1].type != RiaDimension.Double || _ria.dimensions[2].type != RiaDimension.Double) {
                Hub.error("point cloud does not have X, Y, Z dimensions as F64 datatype");
                c.complete(false);
                return;
            }

            var dimlist = _ria.dimensionMap.keys.toList();
            dimlist.add("rgba");

            cloud = new PointCloud(path, name, dimlist);

            for (int x=0; x<_ria.numTilesXAt0; x++) {
                for (int y=0; y<_ria.numTilesYAt0; y++) {
                    String key = "0 $x $y";
                    tileState[key] = CREATABLE;
                }
            }

            var httppath = server.replaceAll("ws:", "http:").replaceAll("12346","12345") + path;
            _hub.cesium.createTileProvider(httppath, _tileCreatorFunc, _tileGetterFunc, _tileStateGetterFunc);

            assert(cloud != null);

            cloud.changeVisibility(isVisible);

            bbox = new CartographicBbox.copy(cloud.bbox);

            _colorizer = new PointCloudColorizer(cloud);

            c.complete(true);
        });

        return c.future;
    }


    Future<PointCloudTile> createTheTile(int tileLevel, int tileX, int tileY, double west, double south, double east, double north) {

        var c = new Completer<PointCloudTile>();

        var tile = new PointCloudTile(cloud, tileLevel, tileX, tileY, west, south, east, north);

        tileState[tile.key] = CREATED;
        tileObjects[tile.key] = tile;

        c.complete(tile);

        //log("created tile ${tile.key}");

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

            tileState[tile.key] = LOADED;

            //log("loaded tile ${tile.key}");

            c.complete(true);
        });

        return c.future;
    }

    void setTheChildren(PointCloudTile tile, int mask) {
        final level = tile.tileLevel;
        final x = tile.tileX;
        final y = tile.tileY;

        var swKey = "${level+1} ${x*2} ${y*2+1}";
        var nwKey = "${level+1} ${x*2} ${y*2}";
        var seKey = "${level+1} ${x*2+1} ${y*2+1}";
        var neKey = "${level+1} ${x*2+1} ${y*2}";

        bool swPresent = (mask & 1 == 1);
        bool sePresent = (mask & 2 == 2);
        bool nePresent = (mask & 4 == 4);
        bool nwPresent = (mask & 8 == 8);

        tileState[swKey] = swPresent ? CREATABLE : NODATA;
        tileState[seKey] = sePresent ? CREATABLE : NODATA;
        tileState[neKey] = nePresent ? CREATABLE : NODATA;
        tileState[nwKey] = nwPresent ? CREATABLE : NODATA;

        if (level == 1) {
            int a = 0;
            int b = 0;
        }
    }


    Future<dynamic> renderTheTile(int tileLevel, int tileX, int tileY) {

        final key = "$tileLevel $tileX $tileY";
        var tile = tileObjects[key];

        var c = new Completer<dynamic>();

        var p;
        if (tile.numPointsInTile == 0) {
            p = null;
        } else {
            tile.updateShape();
            p = tile.shape.primitive;
        }

        c.complete(p);

        tileState[tile.key] = RENDERED;
        tilePrimitives[tile.key] = p;

        //log("rendered tile ${tile.key}");

        return c.future;
    }


    // called from Js: given a tile key...
    int _tileStateGetterFunc(int tileLevel, int tileX, int tileY) {

        final key = "$tileLevel $tileX $tileY";

        //log("state getter request: $key");

        if (!tileState.containsKey(key)) {
            //assert(false);
            return 1;
        }

        assert(tileState.containsKey(key));
        final int state = tileState[key];

        if (state == CREATABLE) {
            return 3;
        }

        if (state == CREATED) {
            return 3;
        }

        if (state == LOADED) {
            return 3;
        }

        if (state == RENDERED) {
            var p = tilePrimitives[key];
            if (p == null) return 2;
            assert(p != null);
            return 4;
        }

        if (state == NODATA) {
            // do nothing
            return 1;
        }

        assert(false);
        return 0;
    }

    // called from Js: given a tile key...
    dynamic _tileGetterFunc(int tileLevel, int tileX, int tileY) {
        final key = "$tileLevel $tileX $tileY";
        if (tileState.containsKey(key)) {
            if (tileState[key] == RENDERED) {
                return tilePrimitives[key];
            }
            if (tileState[key] == LOADED) {
                renderTheTile(tileLevel, tileX, tileY);
                return null;
            }

        }
        return null;
    }

    // called from Js: given a tile key...
    //   - make the tile, if needed
    void _tileCreatorFunc(int tileLevel, int tileX, int tileY, num west, num south, num east, num north, var blob) {
        final key = "$tileLevel $tileX $tileY";

        //log("creator request: $key");

        if (!tileState.containsKey(key)) {
            //assert(false);
            return;
        }

        assert(tileState.containsKey(key));
        final int state = tileState[key];

        if (state == CREATABLE) {
            createTheTile(tileLevel, tileX, tileY, west.toDouble(), south.toDouble(), east.toDouble(), north.toDouble()).then((tile) {
                loadTheTile(tile).then((ok) {
                   //
                });
            });
            return;
        }

        if (state == CREATED) {
            return;
        }

        if (state == LOADED) {
            //renderTheTile(tileLevel, tileX, tileY);
            return;
        }
        if (state == RENDERED) {
            var p = tilePrimitives[key];
            assert(p != null);

            tilePrimitives[key] = null;
            tileState[key] = LOADED;
            return;
        }

        if (state == NODATA) {
            // do nothing
            return;
        }

        assert(false);
        return;
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
