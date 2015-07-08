// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

class LoadScriptDialog extends DialogVM {
  final String _defaultScript = """- layers:
    - bing:
        type: bing_base_imagery
        #style: Road
        style: Aerial
""";

  TextAreaInputVM _scriptText;

  LoadScriptDialog(RialtoFrontend frontend, String id) : super(frontend, id) {
    _scriptText = new TextAreaInputVM(_frontend, "#loadScriptDialog_scriptText", _defaultScript);

    register(_scriptText);
  }

  @override
  void _show() {
    if (_scriptText.getValue() == null || _scriptText.getValue().isEmpty) {
      _scriptText.refresh(_defaultScript);
    }
  }

  @override
  void _hide() {
    String value = _scriptText.getValue();
    if (value != null) {
      _backend.commands.removeAllLayers().then((_) {
        _backend.commands.loadScriptFromStringAsync(value);
      });
    }
  }
}
