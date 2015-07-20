// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

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
