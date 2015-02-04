// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class PointCloudLayer extends Layer {
    PointCloud cloud;
    PointCloudColorizer _colorizer;

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

            Comms comms = new HttpComms(server);

            var ria = new RiaFormat();

            comms.readAll(path + "hdr").then((ByteData buf) {

                ria.readHeader(buf);
                log(ria);
                int pointSize = ria.pointSizeInBytes;

                assert(ria.dimensions[0].name == "X");
                assert(ria.dimensions[1].name == "Y");
                assert(ria.dimensions[2].name == "Z");

                var dimlist = ria.dimensionMap.keys.toList();
                dimlist.add("rgba");

                cloud = new PointCloud(path, name, dimlist);

                var handler = (ByteData buf) {
                    final int numBytes = buf.lengthInBytes;

                    int numPointsInTile = numBytes ~/ pointSize;
                    assert(numPointsInTile * pointSize == numBytes);

                    final int numDims = ria.dimensions.length;
                    List dims = ria.dimensions;

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
                };

                comms.readChunked(path, pointSize, handler).then((bool ok) {
                    if (!ok) return;
                    whenReady();
                });
            });
        }

        return c.future;
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
