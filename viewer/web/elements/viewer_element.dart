library viewer_element;


import 'dart:core';
import 'dart:html';
import 'package:polymer/polymer.dart';
import '../hub.dart';


@CustomTag('viewer-element')
class ViewerElement extends PolymerElement {

    ViewerElement.created() : super.created();


    @override
    void attached() {
        super.attached();
    }


    @override
    void ready() {


        ///  hub.doAddFile("5");
    }


    @override
    void detached() {
        super.detached();
    }


    void goHome(Event e, var detail, Node target) {
        hub.goHome();

        //FauxComms.test();
    }


    void goColorize(Event e, var detail, Node target) {
        hub.doColorize();
    }

}
