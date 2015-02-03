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

                cloud = new PointCloud(path, name, ["xyz", "rgba"]);

                var handler = (ByteBuffer buf, int numBytes) {

                    int numPoints = numBytes ~/ pointSize;
                    assert(numPoints * pointSize == numBytes);


                    ByteData bytes = buf.asByteData();
                    int byteIndex = 0;

                    // gather x,y,z into one array
                    Float32List tmp = new Float32List(numPoints * 3);
                    int tmpIndex = 0;

                    for (int i = 0; i < numPoints; i++) {
                        for (int j = 0; j < 3; j++) {
                            double d = bytes.getFloat64(byteIndex, Endianness.LITTLE_ENDIAN);
                            tmp[tmpIndex] = d;

                            tmpIndex++;
                            byteIndex += 8;
                        }
                        byteIndex += pointSize - 8 * 3;
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
