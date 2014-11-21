library status_element;


import 'dart:core';
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
}
