library rialto.viewer.render_panel;


import 'dart:core';
import 'package:polymer/polymer.dart';
import '../hub.dart';


@CustomTag('render-panel')
class RenderPanel extends PolymerElement {

    Hub _hub = Hub.root;

    RenderPanel.created() : super.created();

    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
        _hub.renderPanel = this;
    }

    @override
    void detached() {
        super.detached();
    }
}
