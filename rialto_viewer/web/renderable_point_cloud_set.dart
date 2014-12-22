// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class RenderablePointCloudSet {
    Hub _hub;
    RenderingContext gl;
    List<RenderablePointCloud> renderablePointClouds = new List<RenderablePointCloud>();
    Vector3 min, max, len;
    int numPoints;
    String _colorRamp = "Spectral";

    RenderablePointCloudSet(RenderingContext this.gl) {
        assert(gl != null);
        _hub = Hub.root;

        min = new Vector3.zero();
        max = new Vector3.zero();
        len = new Vector3.zero();

        _hub.eventRegistry.DisplayLayer.subscribe(_handleDisplayLayer);
        _hub.eventRegistry.ColorizeLayers.subscribe0(_handleColorizeLayers);
        _hub.eventRegistry.UpdateColorizationSettings.subscribe((s) {
            _colorRamp = s;
            _hub.eventRegistry.ColorizeLayers.fire0();
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

        var renderable = new RenderablePointCloud(gl, cloud);
        renderablePointClouds.add(renderable);

        _computeBounds();
    }

    void removeCloud(String webpath) {
        final int len = renderablePointClouds.length;
        renderablePointClouds.removeWhere((rpc) => rpc.pointCloud.webpath == webpath);
        assert(renderablePointClouds.length == len - 1);
        _computeBounds();
    }

    void _handleDisplayLayer(DisplayLayerData data) {
        final String webpath = data.webpath;
        final bool visible = data.visible;
        var rpc = renderablePointClouds.firstWhere((rpc) => rpc.pointCloud.webpath == webpath);
        rpc.visible = visible;
        _hub.mainRenderer.update();
        if (_hub.navRenderer != null) {
            _hub.navRenderer.update();
        }
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
            min = Utils.vectorMinV(min, cloud.min);
            max = Utils.vectorMaxV(max, cloud.max);
            numPoints += cloud.numPoints;
        }

        len = max - min;
    }

    void _handleColorizeLayers() {
        var colorizer = new RampColorizer(_colorRamp);

        for (var cloud in renderablePointClouds) {
            cloud.colorize(colorizer);
        }
        _hub.mainRenderer.update();
    }
}
