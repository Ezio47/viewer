// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

class LoadScriptDialog extends DialogVM {
  StringListInputVM _scriptText;

  LoadScriptDialog(RialtoFrontend frontend, String id) : super(frontend, id) {
    _scriptText = new StringListInputVM(_frontend, "loadScriptDialog_scriptText");

    _trackState(_scriptText);
  }

  @override
  void _show() {
    if (_scriptText.getValueAsString() == null || _scriptText.getValueAsString().isEmpty) {
      String text;
      if (_backend.configScript != null &&
          _backend.configScript.configYaml != null &&
          _backend.configScript.configYaml.isNotEmpty) {
        text = _backend.configScript.configYaml;
      } else {
        text = ConfigScript.defaultYaml;
      }
      _scriptText.setValueFromString(text);
    }
  }

  @override
  void _hide() {
    String value = _scriptText.getValueAsString();
    if (value != null) {
      _backend.commands.removeAllLayers().then((_) {
        _backend.commands.loadScriptFromStringAsync(value);
      });
    }
  }
}
