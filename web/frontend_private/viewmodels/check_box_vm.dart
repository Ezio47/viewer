// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

// TODO: make check to see if data has changed or not

/// UI component for a check box
class CheckBoxVM extends InputVM<bool> {
  InputElement _inputElement;
  bool _disabled;

  CheckBoxVM(RialtoFrontend frontend, String id, bool defaultValue)
      : super(frontend, id, defaultValue),
        _disabled = false {
    _inputElement = _element;
    assert(_inputElement.type == "checkbox");
    _inputElement.checked = getValue();
    _inputElement.onClick.listen((e) => refresh(_inputElement.checked));
  }

  void _elementRefresh(bool v) {
    _inputElement.checked = v;
  }

  // TODO: this should also disable the associated label
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
