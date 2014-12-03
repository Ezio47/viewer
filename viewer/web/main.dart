import 'dart:core';
import 'package:polymer/polymer.dart';
import 'hub.dart';
import 'proxy.dart';

void main() {
    initPolymer().run(() {

        // Code that doesn't need to wait.
        var hub = new Hub();

        Polymer.onReady.then((_) {
            // Code that executes after elements have been upgraded.

            Hub.root.init();

            boot2();
        });
    });
}


void boot2() {
    Hub hub = Hub.root;

    hub.defaultServer = "http://localhost:12345";

    hub.commandRegistry.doOpenServer("http://localhost:12345").then((_) {
        List<FileProxy> list = hub.proxy.root.files;
        FileProxy file1 = list.firstWhere((e) => e.displayName == "serp-100K.ria");

        hub.commandRegistry.doAddFile(file1);

        hub.commandRegistry.doToggleBbox(true);
    });
}

void boot1() {
    Hub hub = Hub.root;

    hub.commandRegistry.doOpenServer("http://www.example.com/").then((_) {
        List<FileProxy> list = hub.proxy.root.files;
        FileProxy file1 = list.firstWhere((e) => e.displayName == "terrain1.dat");
        assert(file1 != null);
        FileProxy file2 = list.firstWhere((e) => e.displayName == "terrain2.dat");
        assert(file2 != null);

        hub.commandRegistry.doAddFile(file1);
        hub.commandRegistry.doAddFile(file2);

        hub.commandRegistry.doToggleBbox(true);
    });
}
