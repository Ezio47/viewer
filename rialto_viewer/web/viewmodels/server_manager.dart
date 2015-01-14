// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class ServerManagerVM extends DialogVM {
    SelectElement _select;
    String _serverName;
    InputElement _serverNameElement;
    String defaultServer;
    String selectedServer;
    bool isServerOpen;
    ControlledList<_ServerProxyItem> items;
    bool isFileSelected;
    var selectedItem;
    bool isSelectionEnabled = true;
    ProxyItem _currentItem = null;
    DirectoryProxy _currentDir = null;

    ServerManagerVM(DialogElement dialogElement, var dollar) : super(dialogElement, dollar) {
        _select = $["serverManagerDialog_files"];
        assert(_select != null);

        items = new ControlledList<_ServerProxyItem>(_select);

        ButtonElement openServer = $["serverManagerDialog_openServer"];
        openServer.onClick.listen((e) => doOpenServer());

        ButtonElement closeServer = $["serverManagerDialog_closeServer"];
        closeServer.onClick.listen((e) => doCloseServer());

        _serverNameElement = $["serverManagerDialog_serverName"];


        if (defaultServer == null) {
            defaultServer = _hub.defaultServer;
        }

        selectedServer = defaultServer;

        Hub.root.eventRegistry.OpenServerCompleted.subscribe0(_handleOpenServerCompleted);
        Hub.root.eventRegistry.CloseServerCompleted.subscribe0(_handleCloseServerCompleted);
    }

    @override
    void _open() {
        if (_hub.proxy != null) {
            // This is a special case: only happens when using a boot script.
            // WHen this happens, we need to prime the items list, as would
            // normally be done in `this.doOpenServer`.
            _currentDir = _hub.proxy.root;
            _loadItemsFromProxy();
            isServerOpen = true;
        }

        _serverNameElement.value = selectedServer;
    }

    @override
    void _close(bool okay) {}

    void doSelectionMade(CustomEvent e) {
        var item = e.detail.data as _ServerProxyItem;
        assert(item != null);
        var source = item.source;
        assert(source != null);
        _currentItem = source;

        isFileSelected = false;

        if (source is FileProxy) {
            isFileSelected = true;

        } else if (source is DirectoryProxy) {
            _currentDir = _currentItem;
            _loadItemsFromProxy();

        } else {
            assert(false);
        }
    }



    void _loadItemsFromProxy() {
        assert(_currentDir != null);

        items.clear();

        if (_currentDir != _hub.proxy.root) {
            // add a fake-out item, representing the parent proxy
            var p = new _ServerProxyItem("..", _currentDir.parent, -1);
            items.add(p);
        }

        for (var s in _currentDir.dirs) {
            var p = new _ServerProxyItem(s.displayName, s, -1);
            items.add(p);
        }
        for (var s in _currentDir.files) {
            assert(s != null);
            assert(s.map != null);
            final int numPoints = s.map.containsKey("size") ? s.map["size"] : -1;
            var p = new _ServerProxyItem(s.displayName, s, numPoints);
            items.add(p);
        }
    }
    void doOpenFile(Event e, var detail, Node target) {
        assert(_currentItem != null);

        _hub.eventRegistry.OpenFile.fire(_currentItem.webpath);

        close(true);
    }
    void _handleCloseServerCompleted() {
        items.clear();

        isServerOpen = false;
        isFileSelected = false;
    }


    void _handleOpenServerCompleted() {
        _currentDir = _hub.proxy.root;
        _loadItemsFromProxy();
        isServerOpen = true;
    }


    void doOpenServer() {
        InputElement t = _serverNameElement;
        assert(t != null);

        if (t.value == null || t.value.isEmpty) {
            _serverName = t.placeholder;
        } else {
            _serverName = t.value;
        }
        if (!_serverName.endsWith("/")) _serverName += "/";

        _hub.eventRegistry.OpenServer.fire(_serverName);
    }


    void doCloseServer() {
        _serverName = null;

        _hub.eventRegistry.CloseServer.fire0();
    }
}



class _ServerProxyItem {
    String name;
    ProxyItem source;
    int numPoints;
    String get size {
        return Utils.toSI(numPoints);
    }

    _ServerProxyItem(displayName, this.source, this.numPoints) {
        name = displayName;
        if (this.source is DirectoryProxy) {
            name += "/";
        }
    }

}
