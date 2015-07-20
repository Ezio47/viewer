// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

class LoadUrlDialog extends DialogVM {
  StringInputVM _urlText;

  LoadUrlDialog(RialtoFrontend frontend, String id) : super(frontend, id) {
    _urlText = new StringInputVM(_frontend, "loadUrlDialog_urlText");
    _trackState(_urlText);
  }

  @override
  void _show() {
    if (_urlText.getValueAsString() == null || _urlText.getValueAsString().isEmpty) {
      Uri uri;
      if (_backend.configScript != null && _backend.configScript.configUri != null) {
        uri = _backend.configScript.configUri;
      } else {
        uri = ConfigScript.defaultUri;
      }
      _urlText.setValueFromString(uri.toString());
    }
  }

  @override
  void _hide() {
    String value = _urlText.getValueAsString();
    if (value != null) {
      var url = Uri.parse(value); // TODO: handle error

      _backend.commands.removeAllLayers().then((_) {
        _backend.commands.loadScriptFromUrl(url);
      });
    }
  }
}
