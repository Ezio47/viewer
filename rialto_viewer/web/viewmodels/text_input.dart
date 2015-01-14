// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class TextInputVM {
    InputElement _element;

    TextInputVM(InputElement this._element, String value) {
        assert(_element != null);
        setValue(value);
    }

    void setValue(String value) {
        _element.value = value;
    }

    String getValueAsString() {
        return _element.value;
    }

    // returns a double or null
    double getValueAsDouble() {
        String s = getValueAsString();
        double d = null;

        d = double.parse(s, (s) {} );
        return d;
    }

    //TODO: add validation for data type of input string
}
