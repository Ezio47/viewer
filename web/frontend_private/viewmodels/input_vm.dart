// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

class StateController {
  final String _defaultValue;
  String _savedValue;
  String _currentValue;

  StateController(String this._defaultValue) {
    _currentValue = _defaultValue;
  }

  void setCurrentValue(String v) {
    _currentValue = v;
  }

  String getCurrentValue() => _currentValue;

  String getDefaultValue() => _defaultValue;

  void saveState() {
    _savedValue = _currentValue;
  }

  void restoreState() {
    _currentValue = _savedValue;
  }

  bool get stateChanged => _savedValue != _currentValue;
}

abstract class InputVM extends ViewModel {
  StateController _stateController;

  InputVM(RialtoFrontend frontend, String id, String defaultValue) : super(frontend, id) {
    _stateController = new StateController(defaultValue);
  }

  void setValueFromString(String v) {
    _setElementValueFromString(v);
    _stateController.setCurrentValue(v);
    //print("control $id is now $v");
  }

  // implement this to set the value on the actual HTML element
  void _setElementValueFromString(String);

  String getValueAsString() => _stateController.getCurrentValue();
}
