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

    void readHeader(ByteData buf) {
        int index = 0;

        int version = buf.getUint8(index);
        index += 1;

        int numPoints = buf.getUint64(index, Endianness.LITTLE_ENDIAN);
        index += 8;

        int numDims = buf.getUint8(index);
        index += 1;

        for (int dim = 0; dim < numDims; dim++) {
            int dimType = buf.getUint16(index, Endianness.LITTLE_ENDIAN);
            index += 2;

            int nameLen = buf.getUint8(index);
            index += 1;

            var chars = new List<int>();
            for (int i = 0; i < nameLen; i++) {
                int c = buf.getUint8(index);
                index += 1;
                chars.add(c);
            }
            String name = UTF8.decode(chars);

            double min = buf.getFloat64(index, Endianness.LITTLE_ENDIAN);
            index += 8;

            double max = buf.getFloat64(index, Endianness.LITTLE_ENDIAN);
            index += 8;
        }

        assert(index == buf.lengthInBytes);
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

            comms.readAll(path + "hdr").then((ByteData buf) {

                readHeader(buf);

                cloud = new PointCloud(path, name, ["xyz", "rgba"]);

                var handler = (ByteBuffer buf, int used) {
                    int numBytes = used;
                    int numFloats = numBytes ~/ 4;
                    int numPoints = numFloats ~/ 3;
                    assert(numPoints * 3 * 4 == numBytes);

                    Float32List tmp = new Float32List.view(buf, 0, numPoints * 3);
                    assert(tmp.length == numPoints * 3);

                    var tile = cloud.createTile(numPoints);
                    tile.addData_F32x3("xyz", tmp);
                    tile.addData_U8x4_fromConstant("rgba", 255, 255, 255, 255);
                    tile.updateBounds();
                    tile.updateShape();
                    cloud.updateBoundsForTile(tile);
                };

                var junk = comms.readChunked(path, handler).then((bool v) {
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
