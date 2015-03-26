// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend;

class LayerAdderDialog extends DialogVM {

    LayerAdderDialog(RialtoFrontend frontend, String id) : super(frontend, id, hasCancelButton: false);
    @override
    void _show();

    @override
    void _hide();
}
