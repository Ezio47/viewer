// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// TODO: make check to see if data has changed or not

class CheckBoxVM extends ViewModel with MStateControl<bool> {
    InputElement _inputElement;
    bool _defaultValue;
    bool _disabled;

    CheckBoxVM(String id, bool this._defaultValue)
            : super(id),
              _disabled = false {
        _inputElement = _element;
        assert(_inputElement.type == "checkbox");

        value = _defaultValue;
    }

    void setClickHandler(var f) {
        _inputElement.onClick.listen((e) => f(e));
    }

    @override
    bool get value => _inputElement.checked;

    @override
    set value(bool value) => _inputElement.checked = value;

    // TODO: this should also disable the associated label
    bool get disabled => _disabled;
    set disabled(bool v) {
        _disabled = v;

        var attrs = _inputElement.attributes;
        if (v) {
            attrs.putIfAbsent("disabled", ()=>"true");
        } else {
            attrs.remove("disabled");
        }
    }
}
