// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class PointCloudSet {
    Hub _hub;
    List<PointCloud> list = new List<PointCloud>();
    Vector3 min, max, len;
    int numPoints = 0;
    String _colorRamp = "Spectral";

    PointCloudSet() {
        _hub = Hub.root;

        min = new Vector3(double.MAX_FINITE, double.MAX_FINITE, double.MAX_FINITE);
        max = new Vector3(-double.MAX_FINITE, -double.MAX_FINITE, -double.MAX_FINITE);
        len = new Vector3.zero();

        _hub.eventRegistry.DisplayLayer.subscribe(_handleDisplayLayer);
        _hub.eventRegistry.ColorizeLayers.subscribe(_handleColorizeLayers);
    }

    int get length => list.length;


    void addClouds(List<PointCloud> clouds) {
        for (var cloud in clouds) {
            addCloud(cloud);
        }
    }

    void addCloud(PointCloud cloud) {
        if (!cloud.hasXyz) throw new RialtoStateError("point cloud must have X, Y, and Z dimensions");

        var renderable = (cloud);
        list.add(renderable);

        _computeBounds();
    }

    void removeCloud(String webpath) {
        var obj = list.firstWhere((rpc) => rpc.webpath == webpath, orElse: () => null);
        if (obj == null) return;

        final int len = list.length;
        list.removeWhere((rpc) => rpc.webpath == webpath);
        assert(list.length == len - 1);
        _computeBounds();
    }

    PointCloud getCloud(String webpath) {
        var obj = list.firstWhere((rpc) => rpc.webpath == webpath, orElse: () => null);
        return obj;
    }

    void _handleDisplayLayer(DisplayLayerData data) {
        final String webpath = data.webpath;
        final bool visible = data.visible;
        var rpc = list.firstWhere((rpc) => rpc.webpath == webpath);
        rpc.isVisible = visible;
        _hub.renderer.updateNeeded = true;
    }

    void _computeBounds() {
        min.x = min.y = min.z = double.MAX_FINITE;
        max.x = max.y = max.z = -double.MAX_FINITE;
        len.x = len.y = len.z = 0.0;

        numPoints = 0;

        if (list.length == 0) {
            return;
        }

        for (var cloud in list) {
            min = Utils.vectorMinV(min, cloud.minimum);
            max = Utils.vectorMaxV(max, cloud.maximum);
            numPoints += cloud.numPoints;
        }

        len = max - min;
    }

    void _handleColorizeLayers(String ramp) {
        _colorRamp = ramp;

        var colorizer = new RampColorizer(_colorRamp);

        for (var cloud in list) {
            cloud.colorize(colorizer);
        }
        _hub.renderer.updateNeeded = true;
    }
}
