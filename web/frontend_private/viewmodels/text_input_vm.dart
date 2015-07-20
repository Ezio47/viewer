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

class PositionString {
  double x, y;
  PositionString([double this.x = 0.0, double this.y = 0.0]);
  String toString() => "$x,$y";

  static PositionString fromString(String str) {
    final begin = r"^";
    final end = r"$";
    final sp = r"\s*";
    final number = r"([0-9]*[.]?[0-9]*)";
    final comma = r",";

    RegExp pattern = new RegExp(begin + sp + number + sp + comma + sp + number + sp + end);
    var match = pattern.firstMatch(str);

    if (match == null) return null;
    if (match.groupCount != 2) return null;

    var x = double.parse(match.group(1));
    var y = double.parse(match.group(2));
    return new PositionString(x, y);
  }
}

class BoxString {
  double north, south, east, west;

  BoxString([double this.north = 0.0, double this.south = 0.0, double this.east = 0.0, double this.west = 0.0]);

  String toString() => "$north,$south,$east,$west";

  static BoxString fromString(String str) {
    final begin = r"^";
    final end = r"$";
    final sp = r"\s*";
    final number = r"([0-9]*[.]?[0-9]*)";
    final comma = r",";

    final A = begin + sp;
    final B = number + sp + comma + number + sp + comma + number + sp + comma + number;
    final C = sp + end;

    RegExp pattern = new RegExp(A + B + C);
    var match = pattern.firstMatch(str);

    if (match == null) return null;
    if (match.groupCount != 4) return null;

    var n = double.parse(match.group(1));
    var s = double.parse(match.group(2));
    var e = double.parse(match.group(3));
    var w = double.parse(match.group(4));
    return new BoxString(n, s, e, w);
  }
}

class PositionInputVM extends _SingleTextInputVM<PositionString> {
  DialogVM _parentDialog;

  PositionInputVM(RialtoFrontend frontend, String id, DialogVM this._parentDialog, PositionString defaultValue)
      : super(frontend, id, defaultValue) {
    var clickHandler = () {
      _parentDialog.temporaryHide();
      _backend.cesium.drawMarker((x, y, z) {
        RialtoBackend.log("Position $x $y $z");
        _parentDialog.temporaryShow();
        setValueFromString("$x,$y");
      });
    };

    new ButtonVM(frontend, id + "_button", (e) => clickHandler());
  }

  PositionString _parse(String s) => PositionString.fromString(s);
}

typedef void BoxClickHandler();

class BoxInputVM extends _SingleTextInputVM<BoxString> {
  final DialogVM _parentDialog;

  BoxInputVM(RialtoFrontend frontend, String id, DialogVM this._parentDialog, BoxString defaultValue)
      : super(frontend, id, defaultValue) {
    BoxClickHandler clickHandler = () {
      _parentDialog.temporaryHide();
      _backend.cesium.drawExtent((north, south, east, west) {
        RialtoBackend.log("Box $north $south $east $west");
        _parentDialog.temporaryShow();
        setValueFromString("$north,$south,$east,$west");
      });
    };

    new ButtonVM(frontend, id + "_button", (e) => clickHandler());
  }

  BoxString _parse(String s) => BoxString.fromString(s);
}
