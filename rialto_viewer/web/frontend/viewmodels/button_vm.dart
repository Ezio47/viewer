// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend;


/// UI component for a button
///
/// Note this is for "regular" buttons, not stateful, toggly buttons.
class ButtonVM extends ViewModel {
    ButtonElement _buttonElement;

    ButtonVM(RialtoFrontend frontend, String id, Function onClick)
            : super(frontend, id) {
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
