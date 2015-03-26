// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class LoadConfigurationDialog extends DialogVM {
    static final _defaultUrl = "http://localhost:12345/file/test.yaml";
    final String _defaultScript = """- layers:
    - bing:
        type: bing_base_imagery
        #style: Road
        style: Aerial
""";

    TextInputVM _urlText;
    ButtonVM _urlButton;
    TextAreaInputVM _scriptText;
    ButtonVM _scriptButton;

    LoadConfigurationDialog(String id) : super(id, hasCancelButton: false) {

        _urlText = new TextInputVM("#loadConfigurationDialog_urlText", "");
        _urlButton = new ButtonVM("#loadConfigurationDialog_urlButton", _loadUrl);

        _scriptText = new TextAreaInputVM("#loadConfigurationDialog_scriptText", "");
        _scriptButton = new ButtonVM("#loadConfigurationDialog_scriptButton", _loadScript);

        _register(_urlText);
    }

    void _loadUrl(_) {
        String value = _urlText.value;
        if (value != null) {
            var url = Uri.parse(value); // TODO: handle error

            _hub.commands.removeAllLayers().then((_) {
                _hub.commands.loadScriptFromUrl(url);
            });
        }
    }

    void _loadScript(_) {
        String value = _scriptText.value;
        if (value != null) {
            _hub.commands.removeAllLayers().then((_) {
                _hub.commands.loadScriptFromStringAsync(value);
            });
        }
    }

    @override
    void _show() {
        if (_urlText.value == null || _urlText.value.isEmpty) {
            _urlText.value = "http://localhost:12345/file/test.yaml";
        }

        if (_scriptText.value == null || _scriptText.value.isEmpty) {
            _scriptText.value = _defaultScript;
        }
    }

    @override
    void _hide() {
    }
}
