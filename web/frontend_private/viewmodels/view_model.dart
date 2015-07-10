// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

/// base class for Rialto's notion of a UI component
abstract class ViewModel {
  RialtoFrontend _frontend;
  RialtoBackend _backend;
  final String id;
  Element _element;

  /// Create a view model for the given HTML element
  ///
  ViewModel(RialtoFrontend this._frontend, String this.id) {
    assert(!id.startsWith("#"));

    _backend = _frontend.backend;

    _element = querySelector("#" + id);
    if (_element == null) {
      throw new ArgumentError("HTML element with id=$id not found");
    }
  }
}

//----------------------------------------------------

class StateTracker {
  List<StateController> _controls = new List<StateController>();

  void _add(InputVM input) {
    _controls.add(input._stateController);
  }

  void saveState() => _controls.forEach((c) => c.saveState());

  void restoreState() => _controls.forEach((c) => c.restoreState());

  bool get stateChanged => _controls.any((c) => c.stateChanged);
}

abstract class FormVM extends ViewModel {
  StateTracker _stateTracker = new StateTracker();

  FormVM(RialtoFrontend frontend, String id) : super(frontend, id);

  void _trackState(InputVM input) {
    _stateTracker._add(input);
  }
}

//----------------------------------------------------

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
