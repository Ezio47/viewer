// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class ColorizationSettingsVM extends VM {
    Hub _hub;

    List<_ColorizationItem> items = new List<_ColorizationItem>();
    var selectedItem;
    bool isSelectionEnabled = true;

    ColorizationSettingsVM(DialogElement dialogElement, var dollar) : super(dialogElement, dollar) {

        _hub = Hub.root;

        _hub = Hub.root;

        var names = RampColorizer.names;
        names.forEach((s) => items.add(new _ColorizationItem(s)));
        $["button3"].disabled = true;
    }

    void doOkay(Event e, var detail, Node target) {
        assert(selectedItem != null);

        _hub.eventRegistry.UpdateColorizationSettings.fire(selectedItem.name);


    }
}

class _ColorizationItem {
    String name;
    ProxyItem source;

    _ColorizationItem(this.name);
}
