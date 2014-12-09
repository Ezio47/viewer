// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// given a point cloud, this will give us an Object3D for WebGL
class RenderablePointCloud {
    PointCloud pointCloud;
    var dims = new Map<String, GeometryAttribute>();
    int numPoints;
    Vector3 min, max, len;
    ParticleSystem _particleSystem;
    bool visible;

    RenderablePointCloud(PointCloud pc) {
        pointCloud = pc;
        visible = true;

        _createRenderArrays();
        _computeBounds();
        //_createParticles();
    }

    void _computeBounds() {
        double xmin = pointCloud.min["positions.x"];
        double ymin = pointCloud.min["positions.y"];
        double zmin = pointCloud.min["positions.z"];
        double xmax = pointCloud.max["positions.x"];
        double ymax = pointCloud.max["positions.y"];
        double zmax = pointCloud.max["positions.z"];

        min = new Vector3(xmin, ymin, zmin);
        max = new Vector3(xmax, ymax, zmax);
        len = new Vector3(xmax - xmin, ymax - ymin, zmax - zmin);
    }

    void _createRenderArrays() {
        int sum = 0;

        numPoints = pointCloud.numPoints;

        var xyz = new GeometryAttribute.float32(numPoints * 3, 3);
        dims["positions"] = xyz;

        int idx = 0;
        Float32List xsrc = pointCloud.dimensions["positions.x"];
        Float32List ysrc = pointCloud.dimensions["positions.y"];
        Float32List zsrc = pointCloud.dimensions["positions.z"];
        for (int i = 0; i < pointCloud.numPoints; i++) {
            xyz.array[idx++] = xsrc[i];
            xyz.array[idx++] = ysrc[i];
            xyz.array[idx++] = zsrc[i];
        }

        var color = new GeometryAttribute.float32(numPoints * 3, 3);
        dims["colors"] = color;
        idx = 0;

        if (pointCloud.hasColor3) {
            Float32List xsrc = pointCloud.dimensions["colors.x"];
            Float32List ysrc = pointCloud.dimensions["colors.y"];
            Float32List zsrc = pointCloud.dimensions["colors.z"];
            for (int i = 0; i < pointCloud.numPoints; i++) {
                color.array[idx++] = xsrc[i];
                color.array[idx++] = ysrc[i];
                color.array[idx++] = zsrc[i];
            }
        } else {
            for (int i = 0; i < pointCloud.numPoints; i++) {
                color.array[idx++] = 1.0;
                color.array[idx++] = 1.0;
                color.array[idx++] = 1.0;
            }
        }
    }

    ParticleSystem buildParticleSystem() {
        var positions = dims["positions"];
        var colors = dims["colors"];
        assert(positions != null);
        assert(colors != null);

        // the underlying system wants to take ownership of these arrays, so we'll
        // pass them copies
        BufferGeometry geometry = new BufferGeometry();
        geometry.attributes = {
            "position": Utils.clone(positions),
            "color": Utils.clone(colors)
        };

        geometry.computeBoundingSphere();
        var material = new ParticleBasicMaterial(size: 1, vertexColors: 2);

        _particleSystem = new ParticleSystem(geometry, material);
        _particleSystem.name = pointCloud.webpath;
        return _particleSystem;
    }
}
