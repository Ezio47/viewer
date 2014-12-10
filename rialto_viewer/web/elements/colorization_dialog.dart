// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

library rialto.viewer.colorization_dialog;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'idialog.dart';
import '../hub.dart';


@CustomTag('colorization-dialog')
class ColorizationDialog extends PolymerElement implements IDialog {
    Hub _hub;

    @published ObservableList<_ColorizationItem> items = new ObservableList();
    @observable var selectedItem;
    @observable bool isSelectionEnabled = true;

    ColorizationDialog.created() : super.created();

    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
        _hub = Hub.root;
        _hub.colorizationDialog = this;
        var names = RampColorizer.names;
        names.forEach((s) => items.add(new _ColorizationItem(s)));
        $["button3"].disabled = true;
    }

    @override
    void detached() {
        super.detached();
    }

    void openDialog() {
        DialogElement e = this.parent;
        e.showModal();
    }

    void closeDialog() {
        DialogElement e = this.parent;
        e.close("");
    }

    void doCancel(Event e, var detail, Node target) {
        closeDialog();
    }

    void doOkay(Event e, var detail, Node target) {
        assert(selectedItem != null);

        _hub.eventRegistry.UpdateColorizationSettings.fire(selectedItem.name);

        closeDialog();
    }
    void doSelectionMade(CustomEvent e) {
        $["button3"].disabled = false;

        //var item = e.detail.data as _ColorizationItem;
        //assert(item != null);
        //_currentItem = item.name;

    }
}

class _ColorizationItem extends Observable {
    @observable String name;
    ProxyItem source;

    _ColorizationItem(this.name);
}
