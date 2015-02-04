// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class PointCloudLayer extends Layer {
    PointCloud cloud;

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
                dimlist.add("xyz");
                dimlist.add("rgba");
                dimlist.remove("X");
                dimlist.remove("Y");
                dimlist.remove("Z");

                cloud = new PointCloud(path, name, dimlist);

                var handler = (ByteBuffer buf, int numBytes) {

                    int numPoints = numBytes ~/ pointSize;
                    assert(numPoints * pointSize == numBytes);

                    final int numDims = ria.dimensions.length;
                    List dims = ria.dimensions;

                    ByteData bytes = buf.asByteData();

                    // read the data into the array inside each RiaDim
                    int index = 0;
                    for (int i = 0; i < numPoints; i++) {
                        for (int j = 0; j < numDims; j++) {
                            RiaDimension dim = dims[j];
                            dim.setter(bytes, index, i);
                            index += dim.sizeInBytes;
                        }
                    }

                    var tile = cloud.createTile(numPoints);

                    // now move the data from RiaDim into the tile
                    // skip X, Y, and Z since we'll add those as a special "xyz"
                    for (int j = 0; j < numDims; j++) {
                        RiaDimension dim = dims[j];
                        if (dim.name == "X" || dim.name == "Y" || dim.name == "Z") continue;
                        List list = dim.list;
                        tile.addData_generic(dim.name, list);
                    }

                    // gather x,y,z into one array
                    Float64List xyz = new Float64List(numPoints * 3);
                    var xlist = dims[0].list;
                    var ylist = dims[1].list;
                    var zlist = dims[2].list;
                    for (int i = 0; i < numPoints; i++) {

                        double x = xlist[i];
                        double y = ylist[i];
                        double z = zlist[i];

                        xyz[i * 3] = x;
                        xyz[i * 3 + 1] = y;
                        xyz[i * 3 + 2] = z;
                    }
                    tile.addData_F64x3("xyz", xyz);

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
}
