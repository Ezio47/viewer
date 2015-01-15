// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


InfoVM infobox; // BUG

class InfoVM extends DialogVM {

    Hub _hub;

    InfoVM(DialogElement dialogElement, var dollar) : super(dialogElement, dollar, hasCancelButton: false) {
        infobox = this;
    }

    @override
    void _open() {}

    @override
    void _close(bool okay) {}

    void changeDataExtents(int numPoints, Vector3 min, Vector3 max) {
        $["infoDialog_numPoints"].text = numPoints.toString();

        $["infoDialog_minX"].text = min.x.toStringAsFixed(3);
        $["infoDialog_minY"].text = min.y.toStringAsFixed(3);
        $["infoDialog_minZ"].text = min.z.toStringAsFixed(3);

        $["infoDialog_maxX"].text = max.x.toStringAsFixed(3);
        $["infoDialog_maxY"].text = max.y.toStringAsFixed(3);
        $["infoDialog_maxZ"].text = max.z.toStringAsFixed(3);
    }
}
