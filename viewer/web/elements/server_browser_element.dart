library server_browser_element;


import 'dart:core';
import 'dart:html';
import 'package:polymer/polymer.dart';
import '../hub.dart';
import '../proxy.dart';
import '../utils.dart';


@CustomTag('server-browser-element')
class ServerBrowserElement extends PolymerElement {

    Hub _hub = Hub.root;

    String _server;
    @observable bool isServerOpen;
    @observable bool isFileSelected;

    @observable var selectedItem;
    @observable bool isSelectionEnabled = true;

    @published ObservableList<_ProxyItem> items = new ObservableList();

    Proxy _currentItem = null;


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
        var e = _hub.mainWindow.$["collapse6"];
        assert(e != null);
        e.toggle();

        if (_hub.proxy != null) {
            // This is a special case: only happens when using a boot script.
            // WHen this happens, we need to prime the items list, as would
            // normally be done in `this.doOpenServer`.
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

        if (t.value == null || t.value.isEmpty)
            _server = t.placeholder;
        else
            _server = t.value;

        if (!_server.endsWith("/"))
            _server += "/";

        _hub.commandRegistry.doOpenServer(_server);

        _loadItemsFromProxy();

        isServerOpen = true;
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
        items.clear();

        if (_hub.proxy is! ServerProxy) {
            // add a fake-out item, representing the parent proxy
            items.add(new _ProxyItem("..", _hub.proxy.parent, -1));
        }

        for (var s in _hub.proxy.sources) {
            int numPoints = (s is FileProxy) ? (s as FileProxy).numPoints : -1;
            items.add(new _ProxyItem(s.name, s, numPoints));
        }
    }

    void doSelectionMade(CustomEvent e) {
        var item = e.detail.data as _ProxyItem;
        assert(item != null);
        var source = item.source;
        _currentItem = source;

        isFileSelected = false;

        if (source is FileProxy) {
            isFileSelected = true;

        } else if (source is DirectoryProxy || source is ServerProxy) {
            _hub.proxy = source;
            _hub.proxy.load();
            _loadItemsFromProxy();

        } else {
            assert(false);
        }
    }
}


class _ProxyItem extends Observable {
    @observable String name;
    Proxy source;
    @observable int numPoints;
    @observable String get size { return Utils.toSI(numPoints); }

    _ProxyItem(this.name, this.source, this.numPoints);
}
