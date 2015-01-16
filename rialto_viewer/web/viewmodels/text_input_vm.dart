// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class TextInputVM extends ViewModel {
    InputElement _inputElement;
    String defaultValue;
    String _startingValue;

    TextInputVM(String id, String this.defaultValue) : super(id) {
        _inputElement = _element;
        value = defaultValue;
    }

    void clearState() {
        _startingValue = value;
    }

    bool get changed {
        return (_startingValue != value);
    }

    String get value {
        return _inputElement.value;
    }

    set value(String value) {
        _inputElement.value = value;
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
