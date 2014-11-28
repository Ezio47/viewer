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

    @published ObservableList<Item> items = new ObservableList();
    Proxy _proxy = null;
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

    void _closePanel() {
        var e = Hub.root.mainWindow.$["collapse6"];
        assert(e != null);
        e.toggle();
    }

    void doCloseServer(Event e, var detail, Node target) {
        _server = null;

        if (_proxy != null)
        {
            _proxy.close();
            _proxy = null;
        }

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

        _proxy = new ServerProxy(_server);
        _proxy.load();
        loadItems();

        isServerOpen = true;
    }

    void doCancel(Event e, var detail, Node target) {
        _closePanel();
    }

    void doOpenFile(Event e, var detail, Node target) {
        assert(_currentItem != null);
        _hub.doAddFile(_currentItem);

        _closePanel();
    }

    void loadItems() {
        items.clear();

        if (_proxy is! ServerProxy) items.add(new Item("..", null, -1));

        for (var s in _proxy.sources) {
            int numPoints = (s is FileProxy) ? (s as FileProxy).numPoints : -1;
            items.add(new Item(s.name, s, numPoints));
        }
    }

    void openItem(Event e, var detail, Node target) {  }

    void doSelectionMade(CustomEvent e) {
        var item = e.detail.data as Item;
        assert(item != null);
        var source = item.source;
        _currentItem = source;

        isFileSelected = false;

        if (item.name == "..") {
            _proxy = _proxy.parent;
            loadItems();

        } else if (source is FileProxy) {
            //window.alert(item.name);
            isFileSelected = true;

        } else if (source is DirectoryProxy) {
            _proxy = source;
            _proxy.load();
            loadItems();

        } else {
            assert(false);
        }

    }
}


class Item extends Observable {
    Item(this.name, this.source, this.numPoints);
    @observable String name;
    Proxy source;
    @observable int numPoints;
    @observable String get size { return Utils.toSI(numPoints); }
}

