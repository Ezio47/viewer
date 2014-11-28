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
    Proxy proxy = new ServerProxy("http://www.example.com/");
    proxy.load();
    List<Proxy> list = proxy.sources;
    proxy = list.firstWhere((e) => e.name == "terrain1.dat");
    //proxy = list.firstWhere((e) => e.name == "oldcube.dat");
    assert(proxy != null);
    hub.commandRegistry.doAddFile(proxy);
    proxy = list.firstWhere((e) => e.name == "terrain2.dat");
    hub.commandRegistry.doAddFile(proxy);
    hub.commandRegistry.doToggleBbox(true);
}