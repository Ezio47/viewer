// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

class AdvancedSettingsDialog extends DialogVM {
  CheckBoxVM _bboxEnabled;

  TextInputVM _displayPrecision;

  AdvancedSettingsDialog(RialtoFrontend frontend, String id) : super(frontend, id) {
    _displayPrecision = new TextInputVM(_frontend, "advancedSettingsDialog_displayPrecision", "5");

    _backend.events.AdvancedSettingsChanged.subscribe(_handleChange);
    _bboxEnabled = new CheckBoxVM(_frontend, "advancedSettingsDialog_bboxEnabled", true);

    _trackState(_bboxEnabled);
    _trackState(_displayPrecision);
  }

  void _handleChange(AdvancedSettingsChangedData data) {
    _displayPrecision.setValue(data.displayPrecision.toString());
  }

  @override
  void _show() {}

  @override
  void _hide() {
    var data = new AdvancedSettingsChangedData(_bboxEnabled.getValue(), _displayPrecision.valueAsInt);
    _backend.events.AdvancedSettingsChanged.fire(data);
  }
}
