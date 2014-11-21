library render_element;


import 'dart:core';
import 'package:polymer/polymer.dart';
import '../hub.dart';


@CustomTag('render-element')
class RenderElement extends PolymerElement {

    Hub _hub = Hub.root;

    RenderElement.created() : super.created();

    @override
    void attached() {
        super.attached();

        var canvas = this.shadowRoot.querySelector("#container");
        assert(canvas != null);

        _hub.renderUI = this;
        _hub.canvas = canvas;

        canvas.onMouseMove.listen(onMyMouseMove);

        _hub.makeRenderer();
    }

    @override
    void detached() {
        super.detached();
    }


    void onMyMouseMove(event) {
        _hub.doMouseMoved();
    }
}
