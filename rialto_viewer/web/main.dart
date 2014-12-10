// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

import 'dart:core';
import 'package:vector_math/vector_math.dart';
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


void boot1() {
    Hub hub = Hub.root;

    hub.defaultServer = "http://www.example.com/";

    hub.eventRegistry.fireOpenServer(hub.defaultServer);

    hub.eventRegistry.subscribeOpenServerCompleted((_) {
        hub.eventRegistry.fireOpenFile("/terrain1.dat");
        hub.eventRegistry.fireOpenFile("/terrain2.dat");

        hub.eventRegistry.fireDisplayBbox(true);

        hub.eventRegistry.fireColorizeLayers();

        //hub.eventRegistry.fireUpdateCameraEyePosition(new Vector3(-200.0,-500.0,-200.0));
        //hub.eventRegistry.fireUpdateCameraTargetPosition(new Vector3(1500.0,1500.0,1500.0));
    });
}


void boot2() {
    Hub hub = Hub.root;

    hub.defaultServer = "http://localhost:12345";

    hub.eventRegistry.fireOpenServer(hub.defaultServer);

    hub.eventRegistry.subscribeOpenServerCompleted((_) {
        List<FileProxy> list = hub.proxy.root.files;
        FileProxy file1 = list.firstWhere((e) => e.displayName == "autzen-10.ria");

        hub.eventRegistry.fireOpenFile("/autzen-10.ria");

        hub.eventRegistry.fireDisplayBbox(true);

        hub.eventRegistry.fireColorizeLayers();
    });
}
