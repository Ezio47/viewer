// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

class AdvancedSettingsDialog extends DialogVM {
  CheckBoxVM _bboxEnabled;

  IntInputVM _displayPrecision;

  AdvancedSettingsDialog(RialtoFrontend frontend, String id) : super(frontend, id) {
    _displayPrecision = new IntInputVM(_frontend, "advancedSettingsDialog_displayPrecision");

    _backend.events.AdvancedSettingsChanged.subscribe(_handleChange);
    _bboxEnabled = new CheckBoxVM(_frontend, "advancedSettingsDialog_bboxEnabled", true);

    _trackState(_bboxEnabled);
    _trackState(_displayPrecision);
  }

  void _handleChange(AdvancedSettingsChangedData data) {
    _displayPrecision.setValueFromString(data.displayPrecision.toString());
  }

  @override
  void _show() {}

  @override
  void _hide() {
    var data = new AdvancedSettingsChangedData(_bboxEnabled.getValueAsBool(), _displayPrecision.valueAs);
    _backend.events.AdvancedSettingsChanged.fire(data);
  }
}
