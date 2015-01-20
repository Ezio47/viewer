// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class PointCloudSet {
    Hub _hub;
    List<PointCloud> renderablePointClouds = new List<PointCloud>();
    Vector3 min, max, len;
    int numPoints = 0;
    String _colorRamp = "Spectral";

    PointCloudSet() {
        _hub = Hub.root;

        min = new Vector3(double.MAX_FINITE, double.MAX_FINITE, double.MAX_FINITE);
        max = new Vector3(-double.MAX_FINITE, -double.MAX_FINITE, -double.MAX_FINITE);
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
        if (!cloud.hasXyz) throw new RialtoStateError("point cloud must have X, Y, and Z dimensions");

        var renderable = (cloud);
        renderablePointClouds.add(renderable);

        _computeBounds();
    }

    void removeCloud(String webpath) {
        var obj = renderablePointClouds.firstWhere((rpc) => rpc.webpath == webpath, orElse: () => null);
        if (obj == null) return;

        final int len = renderablePointClouds.length;
        renderablePointClouds.removeWhere((rpc) => rpc.webpath == webpath);
        assert(renderablePointClouds.length == len - 1);
        _computeBounds();
    }

    PointCloud getCloud(String webpath) {
        var obj = renderablePointClouds.firstWhere((rpc) => rpc.webpath == webpath, orElse: () => null);
        return obj;
    }

    void _handleDisplayLayer(DisplayLayerData data) {
        final String webpath = data.webpath;
        final bool visible = data.visible;
        var rpc = renderablePointClouds.firstWhere((rpc) => rpc.webpath == webpath);
        rpc.visible = visible;
        _hub.renderer.updateNeeded = true;
    }

    void _computeBounds() {
        min.x = min.y = min.z = double.MAX_FINITE;
        max.x = max.y = max.z = -double.MAX_FINITE;
        len.x = len.y = len.z = 0.0;

        numPoints = 0;

        if (renderablePointClouds.length == 0) {
            return;
        }

        for (var cloud in renderablePointClouds) {
            min = Utils.vectorMinV(min, cloud.vmin);
            max = Utils.vectorMaxV(max, cloud.vmax);
            numPoints += cloud.numPoints;
        }

        len = max - min;
    }

    void _handleColorizeLayers() {
        var colorizer = new RampColorizer(_colorRamp);

        for (var cloud in renderablePointClouds) {
            cloud.colorize(colorizer);
        }
        _hub.renderer.updateNeeded = true;
    }
}
