// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


/// base class for Rialto's notion of a UI component
abstract class ViewModel {
    final String id;
    Element _element;

    /// Create a view model for the given HTML element
    ///
    /// [id] must start with a '#'
    ViewModel(String this.id) {
        assert(id.startsWith("#"));

        _element = querySelector(id);
        if (_element == null) {
            throw new ArgumentError("HTML element with id=$id not found");
        }
    }
}


/// mixin class for a UI component that contains other components (that need to track state)
abstract class IForm {
    List<MStateControl> controls = new List();
    _register(MStateControl c) => controls.add(c);
    void saveState() => controls.forEach((c) => c.saveState());
    void restoreState() => controls.forEach((c) => c.restoreState());
    bool get anyStateChanged => controls.any((c) => c.stateChanged);
}


// /mixin class for a UI component that needs to track state
abstract class MStateControl<T> {
    T _startingValue;

    void saveState() {
        _startingValue = value;
    }

    void restoreState() {
        value = _startingValue;
    }

    bool get stateChanged {
        return (_startingValue != value);
    }

    T get value;
    set value(T);
}
