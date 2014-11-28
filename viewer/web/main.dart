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

            boot1();

        });
    });
}

void boot1()
{
    Hub hub = Hub.root;

    hub.commandRegistry.doOpenServer("http://www.example.com/");
    List<Proxy> list = hub.proxy.sources;
    Proxy file1 = list.firstWhere((e) => e.name == "terrain1.dat");
    assert(file1 != null);
    Proxy file2 = list.firstWhere((e) => e.name == "terrain2.dat");
    assert(file2 != null);

    hub.commandRegistry.doAddFile(file1);
    hub.commandRegistry.doAddFile(file2);

    hub.commandRegistry.doToggleBbox(true);
}