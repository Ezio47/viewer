library rialto.viewer.server_browser_element;


import 'dart:core';
import 'dart:html';
import 'package:polymer/polymer.dart';
import '../hub.dart';


@CustomTag('server-browser-element')
class ServerBrowserElement extends PolymerElement {

    Hub _hub = Hub.root;

    String _server;
    @observable bool isServerOpen;
    @observable bool isFileSelected;

    @observable var selectedItem;
    @observable bool isSelectionEnabled = true;

    @published ObservableList<_ProxyItem> items = new ObservableList();

    @observable String defaultServer;

    ProxyItem _currentItem = null;
    DirectoryProxy _currentDir = null;

    ServerBrowserElement.created() : super.created();

    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
        _hub.serverBrowserElement = this;
    }

    @override
    void detached() {
        super.detached();
    }

    void openPanel() {
        if (defaultServer == null) {
            defaultServer = _hub.defaultServer;
        }

        var e = _hub.mainWindow.$["collapse6"];
        assert(e != null);
        e.toggle();

        if (_hub.proxy != null) {
            // This is a special case: only happens when using a boot script.
            // WHen this happens, we need to prime the items list, as would
            // normally be done in `this.doOpenServer`.
            _currentDir = _hub.proxy.root;
            _loadItemsFromProxy();
            isServerOpen = true;
        }
    }

    void _closePanel() {
        var e = _hub.mainWindow.$["collapse6"];
        assert(e != null);
        e.toggle();
    }

    void doCloseServer(Event e, var detail, Node target) {
        _server = null;

        _hub.commandRegistry.doCloseServer();

        items.clear();

        isServerOpen = false;
        isFileSelected = false;
    }

    void doOpenServer(Event e, var detail, Node target) {
        InputElement t = $["servername"];
        assert(t != null);

        if (t.value == null || t.value.isEmpty) {
            _server = t.placeholder;
        } else {
            _server = t.value;
        }
        if (!_server.endsWith("/")) _server += "/";

        _hub.commandRegistry.doOpenServer(_server).then((_) {
            _currentDir = _hub.proxy.root;
            _loadItemsFromProxy();
            isServerOpen = true;
        });
    }

    void doCancel(Event e, var detail, Node target) {
        _closePanel();
    }

    void doOpenFile(Event e, var detail, Node target) {
        assert(_currentItem != null);
        _hub.commandRegistry.doAddFile(_currentItem);

        _closePanel();
    }

    void _loadItemsFromProxy() {
        assert(_currentDir != null);

        items.clear();

        if (_currentDir != _hub.proxy.root) {
            // add a fake-out item, representing the parent proxy
            items.add(new _ProxyItem("..", _currentDir.parent, -1));
        }

        for (var s in _currentDir.dirs) {
            items.add(new _ProxyItem(s.displayName, s, -1));
        }
        for (var s in _currentDir.files) {
            assert(s != null);
            assert(s.map != null);
            final int numPoints = s.map.containsKey("size") ? s.map["size"] : -1;
            items.add(new _ProxyItem(s.displayName, s, numPoints));
        }
    }

    void doSelectionMade(CustomEvent e) {
        var item = e.detail.data as _ProxyItem;
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
}


class _ProxyItem extends Observable {
    @observable String name;
    ProxyItem source;
    @observable int numPoints;
    @observable String get size {
        return Utils.toSI(numPoints);
    }

    _ProxyItem(displayName, this.source, this.numPoints) {
        name = displayName;
        if (this.source is DirectoryProxy) {
            name += "/";
        }
    }
}
