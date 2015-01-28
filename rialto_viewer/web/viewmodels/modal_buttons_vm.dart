// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// only one of the set of buttons can be active at a time
// this calss makes sure that when one is pressed, it fires the right action
// and puts the others in the inactive state

class ModalButtonsVM {
    Hub _hub;
    Map<ButtonElement, ModeData> _map;

    ModalButtonsVM(Map<ButtonElement, ModeData> this._map, ButtonElement first) {
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

    void _handleClick(ButtonElement b) {
        // b should be active, the others go inactive

        ModeData modeData = null;
        _map.keys.forEach((ButtonElement button) {
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

        _hub.events.ChangeMode.fire(modeData);
    }
}
