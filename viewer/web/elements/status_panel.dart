library status_element;


import 'dart:core';
import 'dart:html';
import 'package:polymer/polymer.dart';
import '../hub.dart';


@CustomTag('status-panel')
class StatusPanel extends PolymerElement {
    @published double mousePositionX;
    @published double mousePositionY;

    Hub _hub = Hub.root;

    StatusPanel.created() : super.created();

    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
        _hub.statusPanel = this;
        _hub.eventRegistry.registerMouseMoveHandler(_onMouseMove);
    }

    @override
    void detached() {
        super.detached();
    }

    void _onMouseMove(int x, int y) {
        mousePositionX = _hub.renderer.mouseX;
        mousePositionY = _hub.renderer.mouseY;
    }

    void aboutbox(Event e, var detail, Node target) {
        window.alert("Copyright © RadiantBlue 2014. All rights reserved.");
    }
}
