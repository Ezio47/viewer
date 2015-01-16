// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// given a point cloud, this will give us an Object3D for WebGL
class RenderablePointCloud {
    PointCloud pointCloud;
    var dims = new Map<String, Float32List>();
    int numPoints;
    Vector3 min, max, len;
    CloudShape _cloudShape;
    bool visible;

    RenderablePointCloud(PointCloud pc) {

        pointCloud = pc;
        visible = true;

        _createRenderArrays();
        _computeBounds();
    }

    void _computeBounds() {
        double xmin = pointCloud.minimum("positions.x");
        double ymin = pointCloud.minimum("positions.y");
        double zmin = pointCloud.minimum("positions.z");
        double xmax = pointCloud.maximum("positions.x");
        double ymax = pointCloud.maximum("positions.y");
        double zmax = pointCloud.maximum("positions.z");

        min = new Vector3(xmin, ymin, zmin);
        max = new Vector3(xmax, ymax, zmax);
        len = new Vector3(xmax - xmin, ymax - ymin, zmax - zmin);

        print("Bounds: min=${Utils.printv(min)} max=${Utils.printv(max)} len=${Utils.printv(len)}");
    }

    void _createRenderArrays() {
        int sum = 0;

        numPoints = pointCloud.numPoints;

        var xyz = new Float32List(numPoints * 3);
        dims["positions"] = xyz;

        int idx = 0;
        final int numTiles = pointCloud.dimensions["positions.x"].list.length;
        //log("Reading back $numTiles");

        for (int t = 0; t < numTiles; t++) {
            PointCloudTile xTile = pointCloud.dimensions["positions.x"].list[t];
            PointCloudTile yTile = pointCloud.dimensions["positions.y"].list[t];
            PointCloudTile zTile = pointCloud.dimensions["positions.z"].list[t];

            final int tileSize = xTile.data.length;
            //log("Tile $t size: $tileSize");

            for (int i = 0; i< tileSize; i++) {
                xyz[idx++] = xTile.data[i];
                xyz[idx++] = yTile.data[i];
                xyz[idx++] = zTile.data[i];
            }
        }

        //log(idx);
        //log(numPoints);
        //log(numPoints*3);
        assert(idx == numPoints * 3);

        var color = new Float32List(numPoints * 4);
        dims["colors"] = color;
        idx = 0;

        if (pointCloud.hasColor3) {
            for (int t=0; t<numTiles; t++) {
                PointCloudTile xTile = pointCloud.dimensions["colors.x"].list[t];
                PointCloudTile yTile = pointCloud.dimensions["colors.y"].list[t];
                PointCloudTile zTile = pointCloud.dimensions["colors.z"].list[t];
                final int count = xTile.data.length;
                for (int i = 0; i < count; i++) {
                    color[idx++] = xTile.data[i];
                    color[idx++] = yTile.data[i];
                    color[idx++] = zTile.data[i];
                    color[idx++] = 1.0;
                }
            }
        } else {
            for (int i = 0; i < pointCloud.numPoints; i++) {
                color[idx++] = 1.0;
                color[idx++] = 1.0;
                color[idx++] = 1.0;
                color[idx++] = 1.0;
            }
        }
        assert(idx == numPoints * 4);
    }

    CloudShape buildParticleSystem() {
        var positions = dims["positions"];
        var colors = dims["colors"];
        assert(positions != null);
        assert(colors != null);

        _cloudShape = new CloudShape(positions, colors);
        _cloudShape.name = pointCloud.webpath;
        return _cloudShape;
    }

    void colorize(Colorizer colorizer) {
        var oldColors = dims["colors"];
        var newColors = colorizer.run(this);
        dims["oldcolors"] = oldColors;
        dims["colors"] = newColors;
    }
}
