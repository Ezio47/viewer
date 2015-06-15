// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;


class LoadConfigurationDialog extends DialogVM {
    final String _defaultScript = """- layers:
    - bing:
        type: bing_base_imagery
        #style: Road
        style: Aerial
""";

    TextInputVM _urlText;
    TextAreaInputVM _scriptText;

    LoadConfigurationDialog(RialtoFrontend frontend, String id) : super(frontend, id, hasCancelButton: false) {

        _urlText = new TextInputVM(_frontend, "#loadConfigurationDialog_urlText", "");
        new ButtonVM(_frontend, "#loadConfigurationDialog_urlButton", _loadUrl);

        _scriptText = new TextAreaInputVM(_frontend, "#loadConfigurationDialog_scriptText", "");
        new ButtonVM(_frontend, "#loadConfigurationDialog_scriptButton", _loadScript);

        _register(_urlText);
    }

    void _loadUrl(_) {
        String value = _urlText.value;
        if (value != null) {
            var url = Uri.parse(value); // TODO: handle error

            _backend.commands.removeAllLayers().then((_) {
                _backend.commands.loadScriptFromUrl(url);
            });
        }
    }

    void _loadScript(_) {
        String value = _scriptText.value;
        if (value != null) {
            _backend.commands.removeAllLayers().then((_) {
                _backend.commands.loadScriptFromStringAsync(value);
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
