// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

/// UI component that allows for one-line text entry
class TextInputVM extends InputVM<String> {
  InputElement _inputElement;

  static InputElement makeHtmlTextInputElement(String id, String defaultValue) {
    var t = new InputElement();
    t.id = id;
    t.type = "text";
    return t;
  }

  TextInputVM(RialtoFrontend frontend, String id, String defaultValue) : super(frontend, id, defaultValue) {
    _inputElement = _element;
    _inputElement.value = defaultValue;
    _inputElement.onChange.listen((e) => setValue(_inputElement.value));
  }

  void _setElementValue(String v) {
    _inputElement.value = v;
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

  TextAreaInputVM(RialtoFrontend frontend, String id, String defaultValue) : super(frontend, id, defaultValue) {
    _inputElement = _element;
    _inputElement.value = defaultValue;
    _inputElement.onChange.listen((e) => setValue(_inputElement.value));
  }

  void _setElementValue(String v) {
    _inputElement.value = v;
  }
}

class PositionInputVM extends TextInputVM {
  DialogVM _parentDialog;

  PositionInputVM(RialtoFrontend frontend, DialogVM this._parentDialog, String id, String defaultValue)
      : super(frontend, id, defaultValue) {
    var whenClicked = (event) {
      _parentDialog.temporaryHide();

      _backend.cesium.drawMarker((position) {
        RialtoBackend.log("Pin + $position");
        _parentDialog.temporaryShow();
        setValue("$position");
      });
    };

    new ButtonVM(frontend, id + "_button", whenClicked);
  }
}

class BboxInputVM extends TextInputVM {
  DialogVM _parentDialog;

  BboxInputVM(RialtoFrontend frontend, DialogVM this._parentDialog, String id, String defaultValue)
      : super(frontend, id, defaultValue) {
    var whenClicked = (event) {
      _parentDialog.temporaryHide();

      _backend.cesium.drawExtent((n, s, e, w) {
        RialtoBackend.log("Box + $n + $s + $e + $w");
        _parentDialog.temporaryShow();
        setValue("$n $s $e $w");
      });
    };

    new ButtonVM(frontend, id + "_button", whenClicked);
  }
}
