// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;


class WpsDialog extends DialogVM {

    TextInputVM _lon;
    TextInputVM _lat;

    WpsDialog(RialtoFrontend frontend, String id) : super(frontend, id) {



//        _lon = new TextInputVM(_frontend, "#wpsDialog_lon", "11.11");
  //      _lat = new TextInputVM(_frontend, "#wpsDialog_lat", "22.22");

    //    _register(_lon);
      //  _register(_lat);
    }

    static void makeShell(String name) {
        var div1 = new DivElement();
        div1.id = name + "Dialog";
        div1.classes.add("uk-modal");

        querySelector("#bodybodybody").children.add(div1);

        var div2 = new DivElement();
        div2.classes.add("uk-modal-dialog");
        div1.children.add(div2);

        var div3 = new DivElement();
        div3.classes.add("uk-modal-header");
        div2.children.add(div3);

        var form = new FormElement();
        form.classes.add("uk-form");
        div2.children.add(div3);

        var div4 = new DivElement();
        div2.children.add(div4);

        var div5 = new DivElement();
        div5.classes.add("uk-modal-footer");
        div5.classes.add("uk-text-right");
        div2.children.add(div5);

        var button1 = new ButtonElement();
        button1.id = name + "Dialog_okay";
        button1.classes.add("uk-button");
        button1.classes.add("uk-modal-close");
        div5.children.add(button1);

        var button2 = new ButtonElement();
        button2.id = name + "Dialog_cancel";
        button2.classes.add("uk-button");
        button2.classes.add("uk-modal-close");
        div5.children.add(button2);
    }

    @override
    void _show() {}

    @override
    void _hide() {
        /*
        var longitude = _longitude.valueAsDouble;
        var latitude = _latitude.valueAsDouble;

        final targetOkay = (heading != null && pitch != null && roll != null);
        if (!targetOkay) {
            RialtoBackend.error("Invalid camera settings (heading/pitch/roll)");
            return;
        }

        _backend.commands.zoomToCustom(longitude, latitude, height, heading, pitch, roll);
        */
    }
}
