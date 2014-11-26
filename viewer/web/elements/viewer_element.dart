library viewer_element;


import 'dart:core';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:paper_elements/paper_icon_button.dart';
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


    void toggleCollapse1(Event e, var detail, Node target) {
        var e = $["collapse1"];
        var button = target as PaperIconButton;
        button.icon = e.opened ? "rialto-icons-regular:chevdown" : "rialto-icons-regular:chevup";
        e.toggle();
    }
    void toggleCollapse5(Event e, var detail, Node target) {
        var e = $["collapse5"];
        var button = target as PaperIconButton;
        button.icon = e.opened ? "rialto-icons-regular:chevright" : "rialto-icons-regular:chevleft";
        e.toggle();
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
