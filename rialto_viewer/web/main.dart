// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

import 'dart:core';
import 'rialto.dart';


void main() {
    var hub = new Hub();
    Hub.root.init();
    boot2();
}


void boot0() {
    Hub hub = Hub.root;

    // hub.eventRegistry.DisplayBbox.fire(true);
    //hub.eventRegistry.UpdateCameraEyePosition.fire(new Vector3(-200.0, -200.0, 200.0));
    //hub.eventRegistry.UpdateCameraTargetPosition.fire(new Vector3(0.0, 0.0, 0.0));
}

void boot1() {
    Hub hub = Hub.root;

    hub.defaultServer = "http://www.example.com/";

    hub.eventRegistry.OpenServerCompleted.subscribe0(() {
        //hub.eventRegistry.OpenFile.fire("/dir1/random.dat");
        hub.eventRegistry.OpenFile.fire("/terrain1.dat");
        hub.eventRegistry.OpenFile.fire("/terrain2.dat");
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
        hub.eventRegistry.OpenFile.fire("/serp.ria");
    });

    hub.eventRegistry.OpenFileCompleted.subscribe((_) {
        hub.eventRegistry.DisplayBbox.fire(true);
        hub.eventRegistry.ColorizeLayers.fire0();
    });

    hub.eventRegistry.OpenServer.fire(hub.defaultServer);
}
