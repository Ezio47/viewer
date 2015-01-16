// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class InfoVM extends DialogVM {
    Hub _hub;
    LayerManagerDialogVM _parent;

    InfoVM(String id, LayerManagerDialogVM this._parent) : super(id, hasCancelButton: false) {
    }

    @override
    void _open() {
        int numPoints;
        double minx, miny, minz;
        double maxx, maxy, maxz;

        PointCloud selectedCloud = _parent.currentSelection;

        if (selectedCloud == null) {
            numPoints = 0;
            minx = miny = minz = 0.0;
            maxx = maxy = maxz = 0.0;
        } else {
            numPoints = selectedCloud.numPoints;
            minx = selectedCloud.minimum("positions.x");
            miny = selectedCloud.minimum("positions.y");
            minz = selectedCloud.minimum("positions.z");
            maxx = selectedCloud.maximum("positions.x");
            maxy = selectedCloud.maximum("positions.y");
            maxz = selectedCloud.maximum("positions.z");
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
