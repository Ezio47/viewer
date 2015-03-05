// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class LoadConfigurationDialogVM extends DialogVM {
    TextInputVM _urlControl;

    LoadConfigurationDialogVM(String id) : super(id) {

        _urlControl = new TextInputVM("#loadConfigurationDialog_urlControl", "");

        _register(_urlControl);
    }

    @override
    void _show() {
        if (_urlControl.value == null || _urlControl.value.isEmpty) {
            _urlControl.value = "http://localhost:12345/file/test.yaml";
        }
    }

    @override
    void _hide() {
        String value = _urlControl.value;
        if (value != null) {
            var url = Uri.parse(value); // TODO: handle error
            _hub.commands.loadScriptFromUrl(url);
        }
    }
}
