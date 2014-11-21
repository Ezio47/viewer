library viewer_element;


import 'dart:core';
import 'dart:html';
import 'package:polymer/polymer.dart';
import '../hub.dart';


@CustomTag('viewer-element')
class ViewerElement extends PolymerElement {

    Hub _hub = Hub.root;

    ViewerElement.created() : super.created();


    @override
    void attached() {
        super.attached();
    }


    @override
    void ready() {

        //hub.doAddFile("5");

        _hub.bootup();
    }


    @override
    void detached() {
        super.detached();
    }


    void goHome(Event e, var detail, Node target) {
        _hub.goHome();

        //FauxComms.test();
        //Utils.test_toSI();
    }


    void goColorize(Event e, var detail, Node target) {
        _hub.doColorize();
    }

}
