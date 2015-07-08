// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

class LoadUrlDialog extends DialogVM {
  final String _defaultUrl = "http://localhost:12345/file/test.yaml";

  TextInputVM _urlText;

  LoadUrlDialog(RialtoFrontend frontend, String id) : super(frontend, id) {
    _urlText = new TextInputVM(_frontend, "#loadUrlDialog_urlText", _defaultUrl);

    register(_urlText);
  }

  @override
  void _show() {
    if (_urlText.getValue() == null || _urlText.getValue().isEmpty) {
      _urlText.refresh(_defaultUrl);
    }
  }

  @override
  void _hide() {
    String value = _urlText.getValue();
    if (value != null) {
      var url = Uri.parse(value); // TODO: handle error

      _backend.commands.removeAllLayers().then((_) {
        _backend.commands.loadScriptFromUrl(url);
      });
    }
  }
}
