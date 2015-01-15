// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

abstract class DialogVM extends ViewModel {
    bool _hasCancelButton;
    DialogElement _dialogElement;
    Hub _hub;

    DialogVM(String id, {bool hasCancelButton: true}): super(id),
            _hasCancelButton = hasCancelButton {

        _dialogElement = _element;

        _hub = Hub.root;

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
        _dialogElement.showModal();
        _open();
    }

    void close(bool okay) {
        _close(okay);
        _dialogElement.close("");
    }

    void _open();
    void _close(bool okay);
}
