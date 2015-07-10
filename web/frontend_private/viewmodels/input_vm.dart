// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

class StateController<T> {
  final T _defaultValue;
  T _savedValue;
  T _currentValue;

  StateController(T this._defaultValue) {
    _currentValue = _defaultValue;
  }

  void setCurrentValue(T v) {
    _currentValue = v;
  }

  T getCurrentValue() => _currentValue;

  T getDefaultValue() => _defaultValue;

  void saveState() {
    _savedValue = _currentValue;
  }

  void restoreState() {
    _currentValue = _savedValue;
  }

  bool get stateChanged => _savedValue != _currentValue;
}

abstract class InputVM<T> extends ViewModel {
  StateController<T> _stateController;

  InputVM(RialtoFrontend frontend, String id, T defaultValue) : super(frontend, id) {
    _stateController = new StateController<T>(defaultValue);
  }

  void setValue(T v) {
    _setElementValue(v);
    _stateController.setCurrentValue(v);
    print("control $id is now $v");
  }

  // implement this to set the value on the actual HTML element
  void _setElementValue(T);

  T getValue() => _stateController.getCurrentValue();
}
