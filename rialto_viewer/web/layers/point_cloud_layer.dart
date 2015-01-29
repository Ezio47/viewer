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

            var junk = comms.readAsBytes(path, handler).then((bool v) {
                whenReady();
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
