// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class InfoDialogVM extends DialogVM {
    Layer _target;

    InfoDialogVM(String id) : super(id, hasCancelButton: false);

    set target(Layer layer) => _target = layer;

    @override
    void _show() {
        assert(_target != null);
        Layer layer = _target;

        final name = layer.name;
        final type = layer.type;
        final description = layer.description;

        String url, proxy;
        if (layer.url != null) {
            url = layer.url.toString();
            if (layer.proxy != null) {
                proxy = layer.proxy.toString();
            }
        }

        String minx, miny, minz;
        String maxx, maxy, maxz;
        if (layer.bbox != null) {
            final precision = _hub.displayPrecision;

            minx = layer.bbox.minimum.longitude.toStringAsFixed(precision);
            miny = layer.bbox.minimum.latitude.toStringAsFixed(precision);
            minz = layer.bbox.minimum.height.toStringAsFixed(precision);
            maxx = layer.bbox.maximum.longitude.toStringAsFixed(precision);
            maxy = layer.bbox.maximum.latitude.toStringAsFixed(precision);
            maxz = layer.bbox.maximum.height.toStringAsFixed(precision);
        }

        String numPoints;
        if (layer is PointCloudLayer) {
            numPoints = layer.numPoints.toString();
        }

        querySelector("#infoDialog_name").text = name;
        querySelector("#infoDialog_type").text = type;
        querySelector("#infoDialog_url").text = url;
        querySelector("#infoDialog_proxy").text = proxy;
        querySelector("#infoDialog_description").text = description;

        querySelector("#infoDialog_numPoints").text = numPoints;

        querySelector("#infoDialog_minX").text = minx;
        querySelector("#infoDialog_minY").text = miny;
        querySelector("#infoDialog_minZ").text = minz;

        querySelector("#infoDialog_maxX").text = maxx;
        querySelector("#infoDialog_maxY").text = maxy;
        querySelector("#infoDialog_maxZ").text = maxz;
    }
}
