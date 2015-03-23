// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class TextInputVM extends ViewModel with MStateControl<String> {
    InputElement _inputElement;
    String defaultValue;

    TextInputVM(String id, String this.defaultValue) : super(id) {
        _inputElement = _element;
        value = defaultValue;
    }

    @override
    String get value => _inputElement.value;

    @override
    set value(String value) => _inputElement.value = value;


    // returns a double or null
    double get valueAsDouble {
        String s = value;
        double d = null;

        d = double.parse(s, (s) => 0.0);
        return d;
    }

    // returns a double or null
    int get valueAsInt {
        String s = value;
        int i = null;

        i = int.parse(s, onError: (s) => 0);
        return i;
    }

    //TODO: add validation for data type of input string
}


class TextAreaInputVM extends ViewModel with MStateControl<String> {
    TextAreaElement _inputElement;
    String defaultValue;

    TextAreaInputVM(String id, String this.defaultValue) : super(id) {
        _inputElement = _element;
        value = defaultValue;
    }

    @override
    String get value => _inputElement.value;

    @override
    set value(String value) => _inputElement.value = value;
}
