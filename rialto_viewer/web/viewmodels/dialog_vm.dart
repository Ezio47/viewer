// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

abstract class DialogVM {
    String _id;
    DialogElement _dialogElement;
    var $;
    Hub _hub;

    DialogVM(DialogElement dialogElement, Map dollar)
            : _dialogElement = dialogElement,
              $ = dollar {
        assert(_dialogElement != null);

        _id = _dialogElement.id;

        _hub = Hub.root;

        var openButton = $[_id + "_open"];
        assert(openButton != null);
        openButton.onClick.listen((ev) => open());

        var okayButton = $[_id + "_okay"];
        assert(okayButton != null);
        okayButton.onClick.listen((e) =>
                close(true));

        var cancelButton = $[_id + "_cancel"];
        assert(cancelButton != null);
        cancelButton.onClick.listen((e) =>
                close(false));
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


class LayerSettingsVM extends DialogVM {
    LayerSettingsVM(DialogElement dialogElement, var dollar) : super(dialogElement, dollar);

    @override
    void _open() {}

    @override
    void _close(bool okay) {}
}
