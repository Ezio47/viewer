// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

abstract class _BaseTextInputVM<T> extends InputVM {
  _BaseTextInputVM(RialtoFrontend frontend, String id, T defaultValue) : super(frontend, id, defaultValue.toString()) {}

  void _setElementValueFromString(String v);

  T _parse(String s);

  T get valueAs {
    String s = getValueAsString();
    T t = _parse(s);
    return t;
  }
}

abstract class _SingleTextInputVM<T> extends _BaseTextInputVM<T> {
  InputElement _inputElement;

  static InputElement makeInputElement(String id, {String defaultValue: ""}) {
    var t = new InputElement();
    t.id = id;
    t.type = "text";
    t.value = defaultValue;
    return t;
  }

  _SingleTextInputVM(RialtoFrontend frontend, String id, T defaultValue) : super(frontend, id, defaultValue) {
    _inputElement = _element;
    _inputElement.value = defaultValue.toString();
    _inputElement.onChange.listen((e) => setValueFromString(_inputElement.value));
  }

  void _setElementValueFromString(String v) {
    _inputElement.value = v;
  }

  T _parse(String s);
}

abstract class _MultiTextInputVM<T> extends _BaseTextInputVM<List<T>> {
  TextAreaElement _inputElement;

  _MultiTextInputVM(RialtoFrontend frontend, String id, {List<T> defaultValue: null})
      : super(frontend, id, defaultValue) {
    _inputElement = _element;
    _inputElement.value = defaultValue.toString();
    _inputElement.onChange.listen((e) => setValueFromString(_inputElement.value));
  }

  void _setElementValueFromString(String v) {
    _inputElement.value = v;
  }

  List<T> _parse(String s);
}

class IntInputVM extends _SingleTextInputVM<int> {
  IntInputVM(RialtoFrontend frontend, String id, {int defaultValue: 0}) : super(frontend, id, defaultValue);

  int _parse(String s) {
    int v;
    try {
      v = int.parse(s);
    } catch (e) {
      return null;
    }
    return v;
  }
}

class DoubleInputVM extends _SingleTextInputVM<double> {
  DoubleInputVM(RialtoFrontend frontend, String id, {double defaultValue: 0.0}) : super(frontend, id, defaultValue);

  double _parse(String s) {
    double v;
    try {
      v = double.parse(s);
    } catch (e) {
      return null;
    }
    return v;
  }
}

class StringInputVM extends _SingleTextInputVM<String> {
  StringInputVM(RialtoFrontend frontend, String id, {String defaultValue: ""}) : super(frontend, id, defaultValue);

  String _parse(String s) => s;
}

class StringListInputVM extends _MultiTextInputVM<String> {
  StringListInputVM(RialtoFrontend frontend, String id, {List<String> defaultValue: null})
      : super(frontend, id, defaultValue: defaultValue);

  List<String> _parse(String s) => s.split("\n");
}

class Position {
  double x, y;
}

class Box {
  double x, y;
}

class PositionInputVM extends _SingleTextInputVM<Position> {
  DialogVM _parentDialog;

  PositionInputVM(RialtoFrontend frontend, String id, DialogVM this._parentDialog, {Position defaultValue: null})
      : super(frontend, id, defaultValue) {
    var whenClicked = (event) {
      _parentDialog.temporaryHide();

      _backend.cesium.drawMarker((position) {
        RialtoBackend.log("Position $position");
        _parentDialog.temporaryShow();
        setValueFromString("$position");
      });
    };

    new ButtonVM(frontend, id + "_button", whenClicked);
  }

  Position _parse(String s) {
    return new Position();
  }
}

class BoxInputVM extends _SingleTextInputVM<Box> {
  DialogVM _parentDialog;

  BoxInputVM(RialtoFrontend frontend, String id, Box defaultValue, DialogVM this._parentDialog)
      : super(frontend, id, defaultValue) {
    var whenClicked = (event) {
      _parentDialog.temporaryHide();

      _backend.cesium.drawExtent((a, b, c, d) {
        RialtoBackend.log("Box $a $b $c $d");
        _parentDialog.temporaryShow();
        setValueFromString("");
      });
    };

    new ButtonVM(frontend, id + "_button", whenClicked);
  }

  Box _parse(String s) {
    return new Box();
  }
}
