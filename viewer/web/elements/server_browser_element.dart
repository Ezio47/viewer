library server_browser_element;


import 'dart:core';
import 'dart:html';
import 'package:polymer/polymer.dart';
import '../hub.dart';
import 'package:paper_elements/paper_dialog.dart';
import '../proxy.dart';
import '../utils.dart';


@CustomTag('server-browser-element')
class ServerBrowserElement extends PolymerElement {

    Hub _hub = Hub.root;

    ServerBrowserElement.created() : super.created();

    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
        $["file-list2"].on['core-activate'].listen(handleListChange);

       // _hub.settingsUI = this;
    }

    @override
    void detached() {
        super.detached();
    }


    void openFile(Event e, var detail, Node target) {
        var dlg = this.shadowRoot.querySelector("#openDialog") as PaperDialog;

        _proxy = null;
        _proxy = new ServerProxy("http://www.example.com/");
        _proxy.load();
        loadItems();

        dlg.toggle();
    }

    void openFileCancel(Event e, var detail, Node target) {
        var dlg = this.shadowRoot.querySelector("#openDialog") as PaperDialog;
        dlg.toggle();
    }

    void openFileOkay(Event e, var detail, Node target) {
        /*var dlg = this.shadowRoot.querySelector("#openDialog") as PaperDialog;
        dlg.toggle();
        InputElement elem = this.shadowRoot.querySelector("#filenamearea") as InputElement;
        var txt = elem.value;
        if (txt.trim().isEmpty == false) {
            hub.doAddFile(txt);
        }
        elem.value = "";*/

        assert(_currentItem != null);
        _hub.doAddFile(_currentItem);
    }

    void selectionMade(CustomEvent e) {
    }

    void handleListChange(e) {
        _proxy = null;
        _proxy = new ServerProxy("http://www.example.com/");
        _proxy.load();
        loadItems();

    }

    @observable var itemSelection;
    @observable bool itemSelectionEnabled = true;

    @published ObservableList<Item> items = new ObservableList();
    Proxy _proxy = null;
    Proxy _currentItem = null;

    void loadItems() {
        items.clear();

        if (_proxy is! ServerProxy) items.add(new Item("..", null, -1));

        for (var s in _proxy.sources) {
            int numPoints = (s is FileProxy) ? (s as FileProxy).numPoints : -1;
            items.add(new Item(s.name, s, numPoints));
        }
    }

    void openItem(Event e, var detail, Node target) {

    }

    void itemSelectionMade(CustomEvent e) {
        var item = e.detail.data as Item;
        assert(item != null);
        var source = item.source;
        _currentItem = source;

        if (item.name == "..") {
            _proxy = _proxy.parent;
            loadItems();

        } else if (source is FileProxy) {
            //window.alert(item.name);

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

