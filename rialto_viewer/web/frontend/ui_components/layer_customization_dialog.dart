// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend;


class LayerCustomizationDialog extends DialogVM {
    Layer _target;
    ListBoxVM _rampsListBox;
    ListBoxVM _dimsListBox;
    CheckBoxVM _visibilityButton;
    CheckBoxVM _bboxVisibilityButton;

    LayerCustomizationDialog(RialtoFrontend frontend, String id) : super(frontend, id, hasCancelButton: false) {

        _rampsListBox = new ListBoxVM(_frontend, "#layerCustomizationDialog_colorRamps");
        _dimsListBox = new ListBoxVM(_frontend, "#layerCustomizationDialog_colorDims");

        _visibilityButton = new CheckBoxVM(_frontend, "#layerCustomizationDialog_visibility", true);
        _bboxVisibilityButton = new CheckBoxVM(_frontend, "#layerCustomizationDialog_bboxVisibility", true);

        _register(_rampsListBox);
        _register(_dimsListBox);

    }

    set target(Layer layer) => _target = layer;

    @override
    void _show() {
        final bool colorizer = (_target is PointCloudLayer);
        final bool visibility = (_target is VisibilityControl);
        final bool bboxVisibility = (_target is BboxVisibilityControl);

        if (colorizer) {
            var ramps = _backend.cesium.getColorRampNames();
            ramps.forEach((s) => _rampsListBox.add(s));
            _rampsListBox.value = ramps[0];

            var dims = new Set<String>();
            if (_target is PointCloudLayer) {
                dims.addAll((_target as PointCloudLayer).dimensions);
            }

            dims = dims.toList();
            dims.sort();

            dims.forEach((d) => _dimsListBox.add(d));
            _dimsListBox.value = dims[0];

            _rampsListBox.disabled = false;
            _dimsListBox.disabled = false;
        } else {
            _rampsListBox.disabled = true;
            _dimsListBox.disabled = true;
        }

        if (visibility) {
            _visibilityButton.disabled = false;
            _visibilityButton.setClickHandler((_) {
                (_target as VisibilityControl).visible = _visibilityButton.value;
            });
        } else {
            _visibilityButton.disabled = true;
        }

        if (bboxVisibility) {
            _bboxVisibilityButton.disabled = false;
            _bboxVisibilityButton.setClickHandler((_) {
                (_target as BboxVisibilityControl).bboxVisible = _bboxVisibilityButton.value;
            });
        } else {
            _bboxVisibilityButton.disabled = true;
        }
    }

    @override
    void _hide() {

        String ramp = _rampsListBox.value;
        if (ramp == null) return;

        String dim = _dimsListBox.value;
        if (dim == null) return;

        _backend.commands.colorizeLayers(new ColorizerData(ramp, dim));
    }
}
