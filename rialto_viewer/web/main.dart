// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

import 'dart:core';
//import 'package:vector_math/vector_math.dart';
import 'package:polymer/polymer.dart';
import 'hub.dart';


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
 //       hub.eventRegistry.OpenFile.fire("/dir1/random.dat");
        hub.eventRegistry.OpenFile.fire("/terrain1.dat");
        //hub.eventRegistry.OpenFile.fire("/terrain2.dat");
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
