// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class RenderablePointCloudSet {
    List<RenderablePointCloud> renderablePointClouds = new List<RenderablePointCloud>();
    Vector3 min, max, len;
    int numPoints;

    RenderablePointCloudSet() {
        min = new Vector3.zero();
        max = new Vector3.zero();
        len = new Vector3.zero();
    }

    int get length => renderablePointClouds.length;


    void addClouds(List<PointCloud> clouds) {
        for (var cloud in clouds) {
            addCloud(cloud);
        }
    }

    void addCloud(PointCloud cloud) {
        if (!cloud.hasXYZ) throw new RialtoStateError("point cloud must have X, Y, and Z dimensions");

        var renderable = new RenderablePointCloud(cloud);
        renderablePointClouds.add(renderable);

        _computeBounds();
    }

    void removeCloud(String webpath) {
        final int len = renderablePointClouds.length;
        renderablePointClouds.removeWhere((rpc) => rpc.pointCloud.webpath == webpath);
        assert(renderablePointClouds.length == len - 1);
        _computeBounds();
    }

    void toggleCloud(String webpath, bool on) {
        var rpc = renderablePointClouds.firstWhere((rpc) => rpc.pointCloud.webpath == webpath);
        rpc.visible = on;
    }

    void _computeBounds() {
        if (renderablePointClouds.length == 0) {
            min = new Vector3.zero();
            max = new Vector3.zero();
            len = new Vector3.zero();
            return;
        }

        renderablePointClouds.first.min.copyInto(min);
        renderablePointClouds.first.max.copyInto(max);

        numPoints = 0;
        for (var cloud in renderablePointClouds) {
            min = Utils.vectorMin(min, cloud.min);
            max = Utils.vectorMax(max, cloud.max);
            numPoints += cloud.numPoints;
        }

        len = max - min;
    }

    void colorize() {
        for (var cloud in renderablePointClouds) {
            cloud.colorize();
        }
    }
}
