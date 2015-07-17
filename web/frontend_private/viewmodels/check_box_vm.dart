// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

/// UI component for a check box
class CheckBoxVM extends InputVM {
  InputElement _inputElement;
  bool _disabled;

  CheckBoxVM(RialtoFrontend frontend, String id, bool defaultValue)
      : super(frontend, id, defaultValue.toString()),
        _disabled = false {
    _inputElement = _element;
    assert(_inputElement.type == "checkbox");
    _inputElement.checked = getValueAsBool();
    _inputElement.onClick.listen((e) => setValueFromString(_inputElement.checked.toString()));
  }

  // String -> bool
  static bool _bool_parse(String s) {
    if (s == "true") return true;
    if (s == "false") return false;
    return null;
  }

  bool getValueAsBool() => _bool_parse(getValueAsString());

  @override
  void _setElementValueFromString(String v) {
    _inputElement.checked = _bool_parse(v);
  }

  bool get disabled => _disabled;
  set disabled(bool v) {
    _disabled = v;

    var attrs = _inputElement.attributes;
    if (v) {
      attrs.putIfAbsent("disabled", () => "true");
    } else {
      attrs.remove("disabled");
    }
  }
}
