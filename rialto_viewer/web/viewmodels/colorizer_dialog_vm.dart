// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

// TODO: colorizer should affect only one layer, not all

class ColorizerDialogVM extends DialogVM {
    Hub _hub;
    ListBoxVM<String> _listbox;

    ColorizerDialogVM(String id) : super(id) {

        _hub = Hub.root;

        _listbox = new ListBoxVM<String>("#colorizerDialog_items");

        var names = _hub.cesium.getColorRampNames();
        names.forEach((s) => _listbox.add(s));
    }

    @override
    void _show() {}

    @override
    void _close(bool okay) {
        if (!okay) return;

        List<String> list = _listbox.getCurrentSelection();
        if (list.length == 0) return;

        assert(list.length==1);

        String rampName = list[0];

        _hub.events.ColorizeLayers.fire(new ColorizeLayersData(rampName, "Z"));
    }
}
