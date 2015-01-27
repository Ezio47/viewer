// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


abstract class Layer {
    String name;
    String serverName;
    String serverPath;
    int numBytes;
    String comment;
    bool isLoaded;
    bool isVisible;
    CartographicBbox bbox;

    Layer(String this.name, String this.serverName, String this.serverPath)
            : numBytes = 0,
              comment = null,
              isLoaded = false,
              isVisible = false;
}



class BaseImageryLayer extends Layer {
    BaseImageryLayer(String displayName, String serverName, String serverPath)
            : super(displayName, serverName, serverPath);
}



class BaseTerrainLayer extends Layer {
    BaseTerrainLayer(String displayName, String serverName, String serverPath)
            : super(displayName, serverName, serverPath);
}


class ImageryLayer extends Layer {
    ImageryLayer(String displayName, String serverName, String serverPath) : super(displayName, serverName, serverPath);
}



class TerrainLayer extends Layer {
    TerrainLayer(String displayName, String serverName, String serverPath) : super(displayName, serverName, serverPath);
}


class VectorLayer extends Layer {
    VectorLayer(String displayName, String serverName, String serverPath) : super(displayName, serverName, serverPath);
}


class PointCloudLayer extends Layer {
    PointCloud cloud;

    PointCloudLayer(String displayName, String serverName, String serverPath)
            : super(displayName, serverName, serverPath) {
        log("New pointcloud layer: $displayName .. $serverName .. $serverPath");

        Hub.root.eventRegistry.OpenFile.fire(displayName);
    }

    void load() {
        if (serverName == "http://www.example.com") {
            cloud = PointCloudGenerator.generate(serverPath, name);

        } else {

            Comms comms = new HttpComms(serverName);

            cloud = new PointCloud(serverPath, name, ["xyz", "rgba"]);

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

            var f = comms.readAsBytes(serverPath, handler).then((bool v) {
                // blah
            });
        }

        assert(cloud != null);
    }
}
