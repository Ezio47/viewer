// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class RenderablePointCloudSet {
    List<RenderablePointCloud> renderablePointClouds = new List<RenderablePointCloud>();
    Vector3 min, max, len;
    int numPoints;
    String _colorRamp = "Spectral";

    RenderablePointCloudSet() {
        min = new Vector3.zero();
        max = new Vector3.zero();
        len = new Vector3.zero();

        Hub.root.eventRegistry.subscribeDisplayLayer(_displayLayerHandler);
        Hub.root.eventRegistry.subscribeColorizeLayers((_) => _colorizeLayersHandler());
        Hub.root.eventRegistry.subscribeUpdateColorizationSettings((s) {
            _colorRamp = s;
            Hub.root.eventRegistry.fireColorizeLayers();
        });
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

    void _displayLayerHandler(DisplayLayerData data) {
        final String webpath = data.webpath;
        final bool on = data.on;
        var rpc = renderablePointClouds.firstWhere((rpc) => rpc.pointCloud.webpath == webpath);
        rpc.visible = on;
        Hub.root.renderer.update();
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

    void _colorizeLayersHandler() {
        var colorizer = new RampColorizer(_colorRamp);

        for (var cloud in renderablePointClouds) {
            colorizer.run(cloud);
        }
        Hub.root.renderer.update();
    }
}
