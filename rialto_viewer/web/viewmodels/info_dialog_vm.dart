// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class InfoVM extends DialogVM {
    Hub _hub;
    LayerManagerDialogVM _parent;

    InfoVM(String id, LayerManagerDialogVM this._parent) : super(id, hasCancelButton: false);
    @override
    void _show() {
        int numPoints;
        double minx, miny, minz;
        double maxx, maxy, maxz;

        Layer layer = _parent.currentSelection;

        if (layer == null) {
            numPoints = 0;
            minx = miny = minz = 0.0;
            maxx = maxy = maxz = 0.0;
        } else {
            minx = layer.bbox.minimum.longitude;
            miny = layer.bbox.minimum.latitude;
            minz = layer.bbox.minimum.height;
            maxx = layer.bbox.maximum.longitude;
            maxy = layer.bbox.maximum.latitude;
            maxz = layer.bbox.maximum.height;

            if (layer is PointCloudLayer) {
                numPoints = layer.numPoints;
            }
        }

        if (layer != null) {
            querySelector("#infoDialog_name").text = layer.name;
            querySelector("#infoDialog_layerType").text = layer.runtimeType.toString();
            querySelector("#infoDialog_server").text = layer.server;
            querySelector("#infoDialog_path").text = layer.path;
        }

        querySelector("#infoDialog_numPoints").text = numPoints.toString();

        querySelector("#infoDialog_minX").text = minx.toStringAsFixed(3);
        querySelector("#infoDialog_minY").text = miny.toStringAsFixed(3);
        querySelector("#infoDialog_minZ").text = minz.toStringAsFixed(3);

        querySelector("#infoDialog_maxX").text = maxx.toStringAsFixed(3);
        querySelector("#infoDialog_maxY").text = maxy.toStringAsFixed(3);
        querySelector("#infoDialog_maxZ").text = maxz.toStringAsFixed(3);
    }

    @override
    void _close(bool okay) {}
}
