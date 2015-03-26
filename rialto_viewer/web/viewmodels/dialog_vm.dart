// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

abstract class DialogVM extends ViewModel with IForm {
    bool _hasCancelButton;
    HtmlElement _dialogElement;
    var _dialogProxy;
    Rialto _hub;

    DialogVM(String id, {bool hasCancelButton: true})
            : super(id),
              _hasCancelButton = hasCancelButton {

        _hub = Rialto.root;

        _dialogProxy = _hub.js.registerDialog(id);

        _dialogElement = _element;
        assert(_dialogElement != null);

        var openButton = querySelector(openButtonId);
        if (openButton != null) {
            openButton.onClick.listen((ev) => show());
        }

        var okayButton = querySelector(okayButtonId);
        assert(okayButton != null);
        okayButton.onClick.listen((e) => hide(true));

        if (_hasCancelButton) {
            var cancelButton = querySelector(cancelButtonId);
            assert(cancelButton != null);
            cancelButton.onClick.listen((e) => hide(false));
        }
    }

    String get openButtonId => id + "_open";
    String get okayButtonId => id + "_okay";
    String get cancelButtonId => id + "_cancel";

    void show() {
        _hub.js.showDialog(_dialogProxy);
        saveState();
        _show();
    }

    void hide(bool okay) {
        if (!okay) {
            restoreState();
        } else {
            if (anyStateChanged) {
                _hide();
            }
        }
        _hub.js.hideDialog(_dialogProxy);
    }

    // derived dialogs may reimplement these
    void _show() {}
    void _hide() {} // only called on OK, not Cancel
}
