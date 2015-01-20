// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// given a point cloud, this will give us an Object3D for WebGL
class RenderablePointCloud {
    PointCloud pointCloud;
    List<CloudShape> _cloudShapes = new List<CloudShape>();
    bool visible;
    Vector3 min, max, len;

    RenderablePointCloud(PointCloud this.pointCloud) : visible = true {

        min = new Vector3(pointCloud.minimum["x"], pointCloud.minimum["y"], pointCloud.minimum["z"]);
        max = new Vector3(pointCloud.maximum["x"], pointCloud.maximum["y"], pointCloud.maximum["z"]);
        len = max - min;

        print("Bounds: min=${Utils.printv(min)} max=${Utils.printv(max)} len=${Utils.printv(len)}");
    }

    List<CloudShape> buildParticleSystem() {
        for (PointCloudTile tile in pointCloud.tiles) {

            var positions = tile.data["xyz"];
            var colors = tile.data["rgba"];
            assert(positions != null);
            assert(colors != null);

            var cloudShape = new CloudShape(positions, colors);
            cloudShape.name = "{pointCloud.webpath}-${tile.id}";
            _cloudShapes.add(cloudShape);
        }
        return _cloudShapes;
    }

    void colorize(Colorizer colorizer) {
        colorizer.run(pointCloud);
    }
}
