// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// this is for one-shot buttons, not toggle buttons

class ButtonVM extends ViewModel {
    ButtonElement _buttonElement;

    ButtonVM(String id, Function onClick)
            : super(id) {
        _buttonElement = _element;
        _buttonElement.onClick.listen((e) => onClick(e));
        disabled = false;
    }

    bool get disabled => _buttonElement.attributes.containsKey("disabled");

    set disabled(bool v) {
        final attrs = _buttonElement.attributes;
        if (v) {
            attrs.putIfAbsent("disabled", () => "true");
        } else {
            attrs.remove("disabled");
        }
    }
}


/*
class ToggleButtonVM extends ButtonVM {
    String _notPressedText;
    String _pressedText;

    ToggleButtonVM(String id, Function onClick, {String notPressedText, String pressedText}) :
        super(id, onClick) {
        _notPressedText = notPressedText;
        _pressedText = pressedText;
        pressed = false;
    }

    bool get pressed => _element.classes.contains("uk-active");

    set pressed(bool pressed) {
        if (pressed) {
            _element.classes.add("uk-active");
            if (_pressedText != null) {
                _element.text = _pressedText;
            }
        } else {
            _element.classes.remove("uk-active");
            if (_notPressedText != null) {
                _element.text = _notPressedText;
            }
        }
    }
}
*/
