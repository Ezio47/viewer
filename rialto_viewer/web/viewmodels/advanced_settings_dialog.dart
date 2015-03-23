// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class AdvancedSettingsDialog extends DialogVM {

    CheckBoxVM _bboxEnabled;

    TextInputVM _displayPrecision;

    AdvancedSettingsDialog(String id) : super(id) {

        _displayPrecision = new TextInputVM("#advancedSettingsDialog_displayPrecision", "5");

        _hub.events.AdvancedSettingsChanged.subscribe(_handleChange);
        _bboxEnabled = new CheckBoxVM("#advancedSettingsDialog_bboxEnabled", true);

        _register(_bboxEnabled);
        _register(_displayPrecision);
    }

    void _handleChange(AdvancedSettingsChangedData data) {
        _displayPrecision.value = data.displayPrecision.toString();
    }

    @override
    void _show() {}

    @override
    void _hide() {

        var data = new AdvancedSettingsChangedData(_bboxEnabled.value, _displayPrecision.valueAsInt);
        _hub.events.AdvancedSettingsChanged.fire(data);
    }
}
