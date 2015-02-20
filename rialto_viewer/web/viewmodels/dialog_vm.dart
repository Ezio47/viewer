// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

abstract class DialogVM extends ViewModel {
    bool _hasCancelButton;
    HtmlElement _dialogElement;
    Hub _hub;

    DialogVM(String id, {bool hasCancelButton: true}): super(id),
            _hasCancelButton = hasCancelButton {

        _hub = Hub.root;

        _hub.js.registerDialog("#" + id);

        _dialogElement = _element;
        assert(_dialogElement != null);
        assert(_dialogElement is DialogElement);
        log(_dialogElement.runtimeType);

        var openButton = querySelector("#" + _id + "_open");
        assert(openButton != null);
        openButton.onClick.listen((ev) => open());

        var okayButton = querySelector("#" + _id + "_okay");
        assert(okayButton != null);
        okayButton.onClick.listen((e) => close(true));

        if (_hasCancelButton) {
            var cancelButton = querySelector("#" + _id + "_cancel");
            assert(cancelButton != null);
            cancelButton.onClick.listen((e) => close(false));
        }
    }

    void open() {
        _hub.js.showModalDialog("#" + id);
        _open();
    }

    void close(bool okay) {
        _close(okay);
        _hub.js.closeDialog("#" + id, null);
        return;
    }

    void _open();
    void _close(bool okay);
}
