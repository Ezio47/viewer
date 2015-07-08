// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

/// UI component that allows for one-line text entry
class TextInputVM extends InputVM<String> {
  InputElement _inputElement;

  TextInputVM(RialtoFrontend frontend, String id, String defaultValue)
      : super(frontend, id, defaultValue) {
    _inputElement = _element;
    _inputElement.value = defaultValue;
    _inputElement.onChange.listen((e) => refresh(_inputElement.value));
  }

  /// returns value as a double (or 0.0)
  double get valueAsDouble {
    String s = getValue();
    double d = null;

    d = double.parse(s, (s) => 0.0);
    return d;
  }

  /// returns value as an int (or 0)
  int get valueAsInt {
    String s = getValue();
    int i = null;

    i = int.parse(s, onError: (s) => 0);
    return i;
  }

  // TODO: add validation for data type of input string
}

/// UI component that allows for multi-line text entry
class TextAreaInputVM extends InputVM<String> {
  TextAreaElement _inputElement;

  TextAreaInputVM(RialtoFrontend frontend, String id, String defaultValue)
      : super(frontend, id, defaultValue) {
    _inputElement = _element;
    _inputElement.value = defaultValue;
    _inputElement.onChange.listen((e) => refresh(_inputElement.value));
  }
}
