// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class AdvancedSettingsDialogVM extends DialogVM {
    bool _bboxChecked;
    CheckBoxVM _bboxEnabled;

    Hub _hub;

    AdvancedSettingsDialogVM(String id) : super(id) {

        _hub = Hub.root;

        _hub.events.DisplayBboxUpdate.subscribe((v) => _bboxChecked = v);
        _bboxChecked = false;
        _bboxEnabled = new CheckBoxVM("#advancedSettingsDialog_bboxEnabled", true);
    }

    @override
    void _show() {
        _bboxEnabled.clearState();
    }

    @override
    void _hide(bool okay) {
        if (!okay) return;

        _performBboxWork();
    }

    void _performBboxWork() {
        if (_bboxEnabled.changed) {
            _hub.events.DisplayBboxUpdate.fire(_bboxEnabled.value);
        }
    }
}
