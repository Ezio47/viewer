// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


abstract class Layer {
    String name;
    String server;
    String path;
    int numBytes;
    String description;
    bool isVisible;
    CartographicBbox bbox;

    Layer(String this.name, Map map) {
        server = _required(map, "server");
        path = _required(map, "path");
        numBytes = _optional(map, "numBytes", 0);
        description = _optional(map, "description", null);
        isVisible = _optional(map, "visible", true);
        List<num> v6 = _optional(map, "bbox", null);
        if (v6 == null) {
            bbox = new CartographicBbox.empty();
        } else {
            assert(v6.length == 6);
            v6 = v6.map((i) => i.toDouble()).toList();
            bbox = new CartographicBbox.fromValues(v6[0], v6[1], v6[2], v6[3], v6[4], v6[5]);
        }
    }

    void changeVisibility(bool v) {
        isVisible = v;
    }

    Future<bool> load() {
        var stub = (() {});
        return new Future(stub);
    }

    static dynamic _required(Map map, String key) {
        if (!map.containsKey(key)) {
            throw new Exception();
        }
        return map[key];
    }

    static dynamic _optional(Map map, String key, dynamic defalt) {
        if (!map.containsKey(key)) {
            return defalt;
        }
        return map[key];
    }
}



class BaseImageryLayer extends Layer {
    BaseImageryLayer(String name, Map map)
            : super(name, map);
}



class BaseTerrainLayer extends Layer {
    BaseTerrainLayer(String name, Map map)
            : super(name, map);
}


class ImageryLayer extends Layer {
    ImageryLayer(String name, Map map)
            : super(name, map);
}



class TerrainLayer extends Layer {
    TerrainLayer(String name, Map map)
            : super(name, map);
}


class VectorLayer extends Layer {
    VectorLayer(String name, Map map)
            : super(name, map);
}


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
