// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// BUG: make check to see if data has changed or not

class TextInputVM {
    InputElement _element;
    String _defaultValue;
    String _startingValue;

    TextInputVM(InputElement this._element, String this._defaultValue) {
        assert(_element != null);
        value = _defaultValue;
    }

    void clearState() {
        _startingValue = value;
    }

    bool get changed {
        return (_startingValue != value);
    }

    String get value {
        return _element.value;
    }

    set value(String value) {
        _element.value = value;
    }

    // returns a double or null
    double getValueAsDouble() {
        String s = value;
        double d = null;

        d = double.parse(s, (s) {} );
        return d;
    }

    //TODO: add validation for data type of input string
}
