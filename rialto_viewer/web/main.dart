// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

import 'dart:core';
//import 'package:vector_math/vector_math.dart';
import 'package:polymer/polymer.dart';
import 'hub.dart';
import 'dart:js';
import 'dart:math';
import 'dart:html';
import 'dart:typed_data';

void main() {

    initPolymer().run(() {

            // Code that doesn't need to wait.
            var hub = new Hub();

            Polymer.onReady.then((_) {
                // Code that executes after elements have been upgraded.

                Hub.root.init();


                boot1();
            });
        });


    var csViewer = new JsObject(context['CsViewer'], ['cesiumContainer']);
    var rect1 = csViewer.callMethod('createRect', [-92.0, 20.0, -86.0, 27.0]);
    var rect2 = csViewer.callMethod('createRect', [-120.0, 40.0, -116.0, 47.0]);
    //csViewer.callMethod('removePrimitive', [rect1]);
/*
    var cnt = 1000;
    var ps = new JsObject(context['Float64Array'], [cnt * 3]);
    var cs = new JsObject(context['Uint8Array'], [cnt * 4]);

    var rnd = new Random();
    for (var i = 0; i < cnt; i++) {
        var rx = rnd.nextDouble() * 60.0 + 20.0;
        var ry = rnd.nextDouble() * 60.0 + 20.0;
        var rz = rnd.nextDouble() * 10000.0;
        ps[i * 3 + 0] = -rx;
        ps[i * 3 + 1] = ry;
        ps[i * 3 + 2] = rz;
        cs[i * 4 + 0] = 255;
        cs[i * 4 + 1] = 255;
        cs[i * 4 + 2] = 255;
        cs[i * 4 + 3] = 255;
    }
    var cloud1 = csViewer.callMethod('createCloud', [cnt, ps, cs]);

    var axes = csViewer.callMethod('createAxes', [-100.0, 20.0, 0.0, -50.0, 70, 1000.0 * 1000.0]);

    var bbox = csViewer.callMethod('createBbox', [0.0, 0.0, 0.0, 25.0, 25.0, 1000.0 * 1000.0]);
*/
}

void boot0() {
    Hub hub = Hub.root;

    hub.eventRegistry.DisplayBbox.fire(true);
    //hub.eventRegistry.UpdateCameraEyePosition.fire(new Vector3(-200.0, -200.0, 200.0));
    //hub.eventRegistry.UpdateCameraTargetPosition.fire(new Vector3(0.0, 0.0, 0.0));
}

void boot1() {
    Hub hub = Hub.root;

    hub.defaultServer = "http://www.example.com/";

    hub.eventRegistry.OpenServerCompleted.subscribe0(() {
<<<<<<< HEAD
        hub.eventRegistry.OpenFile.fire("/terrain1.dat");
        hub.eventRegistry.OpenFile.fire("/terrain2.dat");
=======
        hub.eventRegistry.OpenFile.fire("/dir1/random.dat");
        //hub.eventRegistry.OpenFile.fire("/terrain1.dat");
        //hub.eventRegistry.OpenFile.fire("/terrain2.dat");
>>>>>>> FETCH_HEAD
    });

    hub.eventRegistry.OpenFileCompleted.subscribe((webpath) {
        if (webpath == "/terrain2.dat") {
            hub.eventRegistry.DisplayBbox.fire(true);
            //hub.eventRegistry.ColorizeLayers.fire0();
            //hub.eventRegistry.UpdateCameraEyePosition.fire(new Vector3(-200.0, -500.0, -200.0));
            //hub.eventRegistry.UpdateCameraTargetPosition.fire(new Vector3(1500.0, 1500.0, 1500.0));
        }
    });

    hub.eventRegistry.OpenServer.fire(hub.defaultServer);
}


void boot2() {
    Hub hub = Hub.root;

    hub.defaultServer = "http://localhost:12345";

    hub.eventRegistry.OpenServerCompleted.subscribe0(() {
        hub.eventRegistry.OpenFile.fire("/autzen-10.ria");
    });

    hub.eventRegistry.OpenFileCompleted.subscribe((_) {
        hub.eventRegistry.DisplayBbox.fire(true);
        hub.eventRegistry.ColorizeLayers.fire0();
    });

    hub.eventRegistry.OpenServer.fire(hub.defaultServer);
}
