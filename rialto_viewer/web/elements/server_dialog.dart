// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

library rialto.viewer.server_dialog;

import 'dart:core';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'idialog.dart';
import '../hub.dart';


@CustomTag('server-dialog')
class ServerDialog extends PolymerElement implements IDialog {

    Hub _hub;

    String _server;
    @observable String selectedServer;
    @observable bool isServerOpen;
    @observable bool isFileSelected;

    @observable var selectedItem;
    @observable bool isSelectionEnabled = true;

    @published ObservableList<_ProxyItem> items = new ObservableList();

    @observable String defaultServer;

    ProxyItem _currentItem = null;
    DirectoryProxy _currentDir = null;

    ServerDialog.created() : super.created();

    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
        _hub = Hub.root;

        _hub.serverDialog = this;

        if (defaultServer == null) {
            defaultServer = _hub.defaultServer;
        }
        selectedServer = defaultServer;

        Hub.root.eventRegistry.OpenServerCompleted.subscribe(_handleOpenServerCompleted);
        Hub.root.eventRegistry.CloseServerCompleted.subscribe(_handleCloseServerCompleted);
    }

    @override
    void detached() {
        super.detached();
    }

    void openDialog() {
        if (_hub.proxy != null) {
            // This is a special case: only happens when using a boot script.
            // WHen this happens, we need to prime the items list, as would
            // normally be done in `this.doOpenServer`.
            _currentDir = _hub.proxy.root;
            _loadItemsFromProxy();
            isServerOpen = true;
        }

        $["button1"].disabled = !isServerOpen;
        $["button2"].disabled = isServerOpen;
        $["button3"].disabled = true;

        var e = _hub.elementLookup("server-dialog-element");
        e.showModal();
    }

    void closeDialog() {
        var e = _hub.elementLookup("server-dialog-element");
        e.close("");
    }

    void doCloseServer(Event e, var detail, Node target) {
        _server = null;

        _hub.eventRegistry.CloseServer.fire();
    }

    void _handleCloseServerCompleted() {
        items.clear();

        isServerOpen = false;
        isFileSelected = false;

        $["button1"].disabled = !isServerOpen;
        $["button2"].disabled = isServerOpen;
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

        _hub.eventRegistry.OpenServer.fire(_server);
    }

    void _handleOpenServerCompleted() {
        _currentDir = _hub.proxy.root;
        _loadItemsFromProxy();
        isServerOpen = true;

        $["button1"].disabled = !isServerOpen;
        $["button2"].disabled = isServerOpen;
    }

    void doCancel(Event e, var detail, Node target) {
        closeDialog();
    }

    void doOpenFile(Event e, var detail, Node target) {
        assert(_currentItem != null);

        _hub.eventRegistry.OpenFile.fire(_currentItem.webpath);

        closeDialog();
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

        $["button3"].disabled = false;
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
