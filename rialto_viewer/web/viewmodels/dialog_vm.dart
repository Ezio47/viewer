// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

abstract class DialogVM extends ViewModel {
    bool _hasCancelButton;
    HtmlElement _dialogElement;
    var _dialogProxy;
    Hub _hub;

    DialogVM(String id, {bool hasCancelButton: true}): super(id),
            _hasCancelButton = hasCancelButton {

        _hub = Hub.root;

        _dialogProxy = _hub.js.registerDialog(id);

        _dialogElement = _element;
        assert(_dialogElement != null);

        var openButton = querySelector(openButtonId);
        assert(openButton != null);
        openButton.onClick.listen((ev) => open());

        var okayButton = querySelector(okayButtonId);
        assert(okayButton != null);
        okayButton.onClick.listen((e) => close(true));

        if (_hasCancelButton) {
            var cancelButton = querySelector(cancelButtonId);
            assert(cancelButton != null);
            cancelButton.onClick.listen((e) => close(false));
        }
    }

    String get openButtonId => id + "_open";
    String get okayButtonId => id + "_okay";
    String get cancelButtonId => id + "_cancel";

    void open() {
        _hub.js.showModalDialog(_dialogProxy);
        _open();
    }

    void close(bool okay) {
        _close(okay);
        _hub.js.closeDialog(_dialogProxy, null);
        return;
    }

    void _open();
    void _close(bool okay);
}
