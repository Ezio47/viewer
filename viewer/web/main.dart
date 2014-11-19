import 'dart:core';
import 'package:polymer/polymer.dart';


void main() {
    initPolymer().run(() {

        // Code that doesn't need to wait.


        Polymer.onReady.then((_) {
            // Code that executes after elements have been upgraded.


        });
    });
}
