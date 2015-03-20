// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class ColorizerDialogVM extends DialogVM {

    ListBoxVM _rampsListBox;
    ListBoxVM _dimsListBox;

    ColorizerDialogVM(String id) : super(id) {

        _rampsListBox = new ListBoxVM("#colorizerDialog_ramps");
        _dimsListBox = new ListBoxVM("#colorizerDialog_dims");

        _register(_rampsListBox);
        _register(_dimsListBox);
    }

    @override
    void _show() {
        var ramps = _hub.cesium.getColorRampNames();
        ramps.forEach((s) => _rampsListBox.add(s));
        _rampsListBox.value = ramps[0];

        var dims = new Set<String>();

        for (var layer in _hub.layerManager.layers) {
            if (layer is PointCloudLayer) {
                dims.addAll(layer.dimensions);
            }
        }

        dims = dims.toList();
        dims.sort();

        dims.forEach((d) => _dimsListBox.add(d));
        _dimsListBox.value = dims[0];
    }

    @override
    void _hide() {

        String ramp = _rampsListBox.value;
        if (ramp == null) return;

        String dim = _dimsListBox.value;
        if (dim == null) return;

        _hub.commands.colorizeLayers(new ColorizerData(ramp, dim));
    }
}
