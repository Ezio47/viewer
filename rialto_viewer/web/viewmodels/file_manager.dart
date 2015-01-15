// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// BUG: add/remove of files happens right away, not when dialog Okay button pressed

class FileManagerVM extends DialogVM {
    TextInputVM _serverName;
    ListBoxVM<_ProxyItem> _filesList;
    ProxyItem _currentItem = null;
    DirectoryProxy _currentDir = null;
    ButtonElement _openServerButton;
    ButtonElement _closeServerButton;

    FileManagerVM(DialogElement dialogElement, var dollar) : super(dialogElement, dollar) {

        _filesList = new ListBoxVM<_ProxyItem>($["fileManagerDialog_files"]);

        $["fileManagerDialog_addSelectedFiles"].onClick.listen((e) => _doAddFiles());
        $["fileManagerDialog_removeSelectedFiles"].onClick.listen((e) => _doRemoveFiles());

        _openServerButton = $["fileManagerDialog_openServer"];
        _openServerButton.onClick.listen((e) => _doOpenServer());

        _closeServerButton = $["fileManagerDialog_closeServer"];
        _closeServerButton.onClick.listen((e) => _doCloseServer());

        _serverName = new TextInputVM($["fileManagerDialog_serverName"], _hub.defaultServer);

        Hub.root.eventRegistry.OpenServerCompleted.subscribe0(_handleOpenServerCompleted);
        Hub.root.eventRegistry.CloseServerCompleted.subscribe0(_handleCloseServerCompleted);

        if (_hub.currentServer == null) {
            _openServerButton.text = "Open";
            _closeServerButton.text = "(close)";
        } else {
            _openServerButton.text = "(open)";
            _closeServerButton.text = "Close";
        }
    }

    @override
    void _open() {
        /*if (_hub.proxy != null) {
            // This is a special case: only happens when using a boot script.
            // When this happens, we need to prime the items list, as would
            // normally be done in `this.doOpenServer`.
            _currentDir = _hub.proxy.root;
            _loadItemsFromProxy();
            isServerOpen = true;
        }*/

        return;
    }


    @override
    void _close(bool okay) {}


    void _loadItemsFromProxy() {
        assert(_currentDir != null);

        _filesList.clear();

        if (_currentDir != _hub.proxy.root) {
            // add a fake-out item, representing the parent proxy
            var p = new _ProxyItem("..", _currentDir.parent, -1);
            _filesList.add(p, p.name);
        }

        for (var s in _currentDir.dirs) {
            var p = new _ProxyItem(s.displayName, s, -1);
            _filesList.add(p, p.name);
        }
        for (var s in _currentDir.files) {
            assert(s != null);
            assert(s.map != null);
            final int numPoints = s.map.containsKey("size") ? s.map["size"] : -1;
            var p = new _ProxyItem(s.displayName, s, numPoints);
            _filesList.add(p, p.name);
        }
    }


    void _doAddFiles() {
        List<_ProxyItem> list = _filesList.getCurrentSelection();
        list.forEach((i) => _doAddFile(i));
    }


    void _doAddFile(_ProxyItem item) {
        assert(item != null);

        var source = item.source;
        assert(source != null);

        _currentItem = source;

        if (source is FileProxy) {
            log("adding file ${_currentItem.webpath}");
            _hub.eventRegistry.OpenFile.fire(_currentItem.webpath);

        } else if (source is DirectoryProxy) {
            _currentDir = _currentItem;
            _loadItemsFromProxy();

        } else {
            assert(false);
        }
    }


    void _doRemoveFiles() {

        List<_ProxyItem> list = _filesList.getCurrentSelection();
        list.forEach((i) => _doRemoveFile(i));
    }

    void _doRemoveFile(_ProxyItem item) {

        assert(item != null);

        var source = item.source;
        assert(source != null);

        _currentItem = source;

        log("removing file ${_currentItem.webpath}");
        _hub.eventRegistry.CloseFile.fire(_currentItem.webpath);
    }


    void _handleCloseServerCompleted() {
        _filesList.clear();

        _openServerButton.text = "Open";
        _closeServerButton.text = "(close)";
    }


    void _handleOpenServerCompleted() {
        _currentDir = _hub.proxy.root;
        _loadItemsFromProxy();

        _openServerButton.text = "(open)";
        _closeServerButton.text = "Close";
    }


    void _doOpenServer() {
        String serverName = _serverName.value;

        assert(serverName != null && !serverName.isEmpty);

        if (!serverName.endsWith("/")) serverName += "/";

        Hub.root.eventRegistry.OpenServer.fire(serverName);
    }


    void _doCloseServer() {
        Hub.root.eventRegistry.CloseServer.fire0();
    }

}


class _ProxyItem {
    String name;
    ProxyItem source;
    int numPoints;
    String get size {
        return Utils.toSI(numPoints);
    }

    _ProxyItem(displayName, this.source, this.numPoints) {
        name = displayName;
        if (this.source is DirectoryProxy) {
            name += "/";
        }
    }

}
