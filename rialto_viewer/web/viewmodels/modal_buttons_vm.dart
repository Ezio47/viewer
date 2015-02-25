// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// only one of the set of buttons can be active at a time
// this calss makes sure that when one is pressed, it fires the right action
// and puts the others in the inactive state

class ModalButtonsVM {
    Hub _hub;
    Map<AnchorElement, ModeData> _map;

    ModalButtonsVM(Map<AnchorElement, ModeData> this._map, AnchorElement first) {
        _hub = Hub.root;

        _map.keys.forEach((button) {
            assert(button != null);
            assert(_map[button] != null);
            button.onClick.listen((ev) {
                _handleClick(button);
            });
        });

        _handleClick(first);
    }

    void _handleClick(AnchorElement b) {
        // b should be active, the others go inactive

        ModeData modeData = null;
        _map.keys.forEach((AnchorElement button) {
            if (button == b) {
                // activate!
                button.text = button.text.toUpperCase();
                modeData = _map[button];
            } else {
                // deactivate!
                button.text = button.text.toLowerCase();
            }
        });

        assert(modeData != null);

        _hub.commands.changeMode(modeData);
    }
}
