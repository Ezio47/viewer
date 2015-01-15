// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// BUG: make check to see if data has changed or not

class CheckBoxVM extends ViewModel {
    InputElement _inputElement;
    bool _defaultValue;
    bool _startingValue;

    CheckBoxVM(String id, bool this._defaultValue) : super(id) {
        _inputElement = _element;
        assert(_inputElement.type == "checkbox");

        value = _defaultValue;
    }

    void clearState() {
        _startingValue = value;
    }

    bool get changed {
        return (_startingValue != value);
    }

    bool get value {
        return _inputElement.checked;
    }

    set value(bool value) {
        _inputElement.checked = value;
    }
}
