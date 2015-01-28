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
    bool isLoaded;
    bool isVisible;
    CartographicBbox bbox;

    Layer(String this.name, Map map) {
        server = _required(map, "server");
        path = _required(map, "path");
        numBytes = _optional(map, "size", 0);
        description = _optional(map, "description", null);
        isLoaded = _optional(map, "load", true);
        isVisible = _optional(map, "visible", true);
        var v6 = _optional(map, "bbox", null);
        if (v6 == null) {
            bbox = new CartographicBbox.empty();
        } else {
            assert(v6.length == 6);
            bbox = new CartographicBbox.fromValues(v6[0], v6[1], v6[2], v6[3], v6[4], v6[5]);
        }
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

        if (isLoaded) {
            Hub.root.eventRegistry.OpenFile.fire(name);
        }
    }

    void load() {
        var f = () {
            assert(cloud != null);

            bbox = new CartographicBbox.fromValues(
                    cloud.minimum.x,
                    cloud.minimum.y,
                    cloud.minimum.z,
                    cloud.maximum.x,
                    cloud.maximum.y,
                    cloud.maximum.z);

            isLoaded = true;
        };

        if (server == "http://www.example.com") {
            cloud = PointCloudGenerator.generate(path, name);
            f();
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
               f();
            });
        }

    }
}
