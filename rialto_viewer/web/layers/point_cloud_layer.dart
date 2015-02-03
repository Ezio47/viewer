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
                print(ria);
                int pointSize = ria.pointSizeInBytes;

                assert(ria.dimensions[0].name=="X");
                assert(ria.dimensions[1].name=="Y");
                assert(ria.dimensions[2].name=="Z");

                cloud = new PointCloud(path, name, ["xyz", "rgba"]);

                var handler = (ByteBuffer buf, int numBytes) {

                    int numPoints = numBytes ~/ pointSize;
                    assert(numPoints * pointSize == numBytes);

                    final int numDims = ria.dimensions.length;
                    List dims = ria.dimensions;

                    ByteData bytes = buf.asByteData();

                    int index = 0;
                    for (int i = 0; i < numPoints; i++) {
                        for (int j=0; j<numDims; j++) {
                            var v = dims[j].getter(bytes, index);
                            dims[j].list[i] = v;
                            index += dims[j].sizeInBytes;
                        }
                    }

                    // gather x,y,z into one array

                    Float32List tmp = new Float32List(numPoints * 3);
                    for (int i=0; i<numPoints; i++) {

                        double x = dims[0].list[i];
                        double y = dims[1].list[i];
                        double z = dims[2].list[i];

                        tmp[i*3] = x;
                        tmp[i*3 + 1] = y;
                        tmp[i*3 + 2] = z;
                    }

                    var tile = cloud.createTile(numPoints);
                    tile.addData_F32x3("xyz", tmp);
                    tile.addData_U8x4_fromConstant("rgba", 255, 255, 255, 255);
                    tile.updateBounds();
                    tile.updateShape();
                    cloud.updateBoundsForTile(tile);
                };

                var junk = comms.readChunked(path, pointSize, handler).then((bool v) {
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
