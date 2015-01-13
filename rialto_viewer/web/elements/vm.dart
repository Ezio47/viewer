// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class VM {
    String _id;
    DialogElement _dialogElement;
    ButtonElement _okayButton;
    ButtonElement _cancelButton;
    var $;
    Hub _hub;

    VM(DialogElement dialogElement, Map dollar)
            : _dialogElement = dialogElement,
              $ = dollar {
        assert(_dialogElement != null);

        _id = _dialogElement.id;

        _hub = Hub.root;

        _okayButton = $[_id + "_okay"];
        assert(_okayButton != null);
        _cancelButton = $[_id + "_cancel"];
        assert(_cancelButton != null);

        _okayButton.onClick.listen((e) => close(true));
        _cancelButton.onClick.listen((e) => close(false));
    }

    void open() {
        _dialogElement.showModal();
        _open();
    }

    void close(bool okay) {
        _dialogElement.close("");
        _close();
    }

    void _open() {}
    void _close() {}
}


class LayerSettingsVM extends VM {
    LayerSettingsVM(DialogElement dialogElement, var dollar) : super(dialogElement, dollar);
}

