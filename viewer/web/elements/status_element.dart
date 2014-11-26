library status_element;


import 'dart:core';
import 'dart:html';
import 'package:polymer/polymer.dart';
import '../hub.dart';


@CustomTag('status-element')
class StatusElement extends PolymerElement {
    @published double mousePositionX;
    @published double mousePositionY;

    Hub _hub = Hub.root;

    StatusElement.created() : super.created();

    @override
    void attached() {
        super.attached();

        _hub.statusUI = this;
    }

    @override
    void detached() {
        super.detached();
    }

    void aboutbox(Event e, var detail, Node target) {
        window.alert("Copyright © RadiantBlue 2014. All rights reserved.");
    }
}
