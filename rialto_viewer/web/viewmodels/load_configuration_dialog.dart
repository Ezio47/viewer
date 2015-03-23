// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class LoadConfigurationDialog extends DialogVM {
    TextInputVM _urlControl;

    LoadConfigurationDialog(String id) : super(id) {

        _urlControl = new TextInputVM("#loadConfigurationDialog_urlControl", "");

        _register(_urlControl);
    }

    @override
    void _show() {
        if (_urlControl.value == null || _urlControl.value.isEmpty) {
            _urlControl.value = "http://www.example.com:8080/file/config.yaml";
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
