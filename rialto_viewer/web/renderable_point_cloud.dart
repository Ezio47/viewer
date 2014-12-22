// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// given a point cloud, this will give us an Object3D for WebGL
class RenderablePointCloud {
    RenderingContext gl;
    PointCloud pointCloud;
    var dims = new Map<String, Float32List>();
    int numPoints;
    Vector3 min, max, len;
    CloudShape _particleSystem;
    bool visible;

    RenderablePointCloud(RenderingContext this.gl, PointCloud pc) {
        assert(this.gl != null);

        pointCloud = pc;
        visible = true;

        _createRenderArrays();
        _computeBounds();
        //_createParticles();
    }

    void _computeBounds() {
        double xmin = pointCloud.minimum["positions.x"];
        double ymin = pointCloud.minimum["positions.y"];
        double zmin = pointCloud.minimum["positions.z"];
        double xmax = pointCloud.maximum["positions.x"];
        double ymax = pointCloud.maximum["positions.y"];
        double zmax = pointCloud.maximum["positions.z"];

        min = new Vector3(xmin, ymin, zmin);
        max = new Vector3(xmax, ymax, zmax);
        len = new Vector3(xmax - xmin, ymax - ymin, zmax - zmin);
    }

    void _createRenderArrays() {
        int sum = 0;

        numPoints = pointCloud.numPoints;

        var xyz = new Float32List(numPoints * 3 * 3);
        dims["positions"] = xyz;

        int idx = 0;
        Float32List xsrc = pointCloud.dimensions["positions.x"];
        Float32List ysrc = pointCloud.dimensions["positions.y"];
        Float32List zsrc = pointCloud.dimensions["positions.z"];
        for (int i = 0; i < pointCloud.numPoints; i++) {
            xyz[idx++] = xsrc[i];
            xyz[idx++] = ysrc[i];
            xyz[idx++] = zsrc[i];
        }

        var color = new Float32List(numPoints * 3);
        dims["colors"] = color;
        idx = 0;

        if (pointCloud.hasColor3) {
            Float32List xsrc = pointCloud.dimensions["colors.x"];
            Float32List ysrc = pointCloud.dimensions["colors.y"];
            Float32List zsrc = pointCloud.dimensions["colors.z"];
            for (int i = 0; i < pointCloud.numPoints; i++) {
                color[idx++] = xsrc[i];
                color[idx++] = ysrc[i];
                color[idx++] = zsrc[i];
            }
        } else {
            for (int i = 0; i < pointCloud.numPoints; i++) {
                color[idx++] = 1.0;
                color[idx++] = 1.0;
                color[idx++] = 1.0;
            }
        }
    }

    CloudShape buildParticleSystem() {
        var positions = dims["positions"];
        var colors = dims["colors"];
        assert(positions != null);
        assert(colors != null);

        var xyz = positions;
/***
        // the underlying system wants to take ownership of these arrays, so we'll
        // pass them copies
        BufferGeometry geometry = new BufferGeometry();
        geometry.attributes = {
            "position": Utils.clone(positions),
            "color": Utils.clone(colors)
        };

        geometry.computeBoundingSphere();
        var material = new ParticleBasicMaterial(size: 1, vertexColors: 2);
**/
        assert(gl != null);
        _particleSystem = new CloudShape(gl, xyz, colors);
        _particleSystem.init();
        _particleSystem.name = pointCloud.webpath;
        return _particleSystem;
    }
}
