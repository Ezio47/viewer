// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


abstract class ViewModel {
    final String id;
    Element _element;

    ViewModel(String this.id) {
        assert(id.startsWith("#"));

        _element = querySelector(id);
        if (_element == null) {
            throw new ArgumentError("HTML element with id=$id not found");
        }
    }
}


abstract class IForm {
    List<MStateControl> controls = new List();
    register(MStateControl c) => controls.add(c);
    void saveState() => controls.forEach((c) => c.saveState());
    void restoreState() => controls.forEach((c) => c.restoreState());
    bool get anyStateChanged => controls.any((c) => c.stateChanged);
}


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
