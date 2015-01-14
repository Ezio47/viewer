// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// BUG: make check to see if data has changed or not

class CheckboxVM {
    InputElement _element;
    bool _defaultValue;
    bool _startingValue;

    CheckboxVM(InputElement this._element, bool this._defaultValue) {
        assert(_element != null);
        assert(_element.type == "checkbox");

        value = _defaultValue;
    }

    void clearState() {
        _startingValue = value;
    }

    bool get changed {
        return (_startingValue != value);
    }

    bool get value {
        return _element.checked;
    }

    set value(bool value) {
        _element.checked = value;
    }
}
