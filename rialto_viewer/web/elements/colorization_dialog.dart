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

    Hub _hub = Hub.root;

    String _server;

    ColorizationDialog.created() : super.created();

    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
    }

    @override
    void detached() {
        super.detached();
    }

    void openDialog() {
        Hub.root.colorizationDialogElement.showModal();
    }

    void closeDialog() {
        Hub.root.colorizationDialogElement.close("");
    }

    void doCancel(Event e, var detail, Node target) {
        closeDialog();
    }

    void doOkay(Event e, var detail, Node target) {
        closeDialog();
    }
}
