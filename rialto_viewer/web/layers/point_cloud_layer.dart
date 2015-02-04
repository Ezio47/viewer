// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


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
