library rialto.viewer.info_panel;


import 'dart:core';
import 'package:polymer/polymer.dart';
import '../hub.dart';


@CustomTag('info-panel')
class InfoPanel extends PolymerElement {
    @published double minx, maxx, miny, maxy, minz, maxz;
    @published bool hasData = true;
    @published int numPoints;

    Hub _hub = Hub.root;

    InfoPanel.created() : super.created();

    @override
    void attached() {
        super.attached();
    }

    @override
    void ready() {
        _hub.infoPanel = this;
    }

    @override
    void detached() {
        super.detached();
    }



}
