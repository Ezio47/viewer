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
  /// [id] must start with a '#'
  ViewModel(RialtoFrontend this._frontend, String this.id) {
    assert(id.startsWith("#"));

    _backend = _frontend.backend;

    _element = querySelector(id);
    if (_element == null) {
      throw new ArgumentError("HTML element with id=$id not found");
    }
  }
}

//----------------------------------------------------

class StateTracker {
  List<StateControl> _controls = new List<StateControl>();

  void _add(InputVM input) {
    _controls.add(input.stateControl);
  }

  void saveState() => _controls.forEach((c) => c.saveState());

  void restoreState() => _controls.forEach((c) => c.restoreState());

  bool get stateChanged => _controls.any((c) => c.stateChanged);
}

abstract class FormVM extends ViewModel {
  StateTracker stateTracker;

  FormVM(RialtoFrontend frontend, String id) : super(frontend, id) {
    stateTracker = new StateTracker();
  }
  void register(InputVM input) {
    stateTracker._add(input);
  }
}

//----------------------------------------------------

class StateControl<T> {
  final T _defaultValue;
  T _savedValue;
  T _currentValue;

  StateControl(T this._defaultValue) {
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
  StateControl<T> stateControl;

  InputVM(RialtoFrontend frontend, String id, T defaultValue) : super(frontend, id) {
    stateControl = new StateControl<T>(defaultValue);
  }

  void refresh(T v) {
    _elementRefresh(v);
    _controlRefresh(v);
  }

  void _elementRefresh(T);

  void _controlRefresh(T v) {
    stateControl.setCurrentValue(v);
    print("control $id is now $v");
  }

  T getValue() => stateControl.getCurrentValue();
}
