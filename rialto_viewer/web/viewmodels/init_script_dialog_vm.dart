// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class InitScriptDialogVM extends DialogVM {
    TextInputVM _serverName;
    TextInputVM _scriptName;
    ListBoxVM<_ScriptItem> _listbox;

    InitScriptDialogVM(String id) : super(id) {

        _serverName = new TextInputVM("initScriptDialog_serverName", "");
        _scriptName = new TextInputVM("initScriptDialog_scriptName", "");

        _listbox = new ListBoxVM<_ScriptItem>("initScriptDialog_files");
        _listbox.setSelectHandler(_selectHandler);

        _listbox.add(new _ScriptItem("http://localhost:12345", "/test.json"));
        _listbox.add(new _ScriptItem("http://localhost:12345", "/test2.json"));
        _listbox.add(new _ScriptItem("http://www.example.com", "/foo.json"));
    }

    @override
    void _open() {}

    @override
    void _close(bool okay) {
        if (!okay) return;

        var url = _serverName.value + _scriptName.value;
        var s = new InitScript(url);

    }

    void _selectHandler(var e) {
        List<_ScriptItem> items = _listbox.getCurrentSelection();
        if (items==null) return;
        if (items[0] == null) return;

        _serverName.value = items[0].server;
        _scriptName.value = items[0].path;
    }
}


class _ScriptItem {
    String server;
    String path;

    _ScriptItem(String this.server, String this.path);

    String toString() {
        return server + path;
    }
}
