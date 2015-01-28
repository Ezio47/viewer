// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

import 'dart:core';
import 'rialto.dart';


void main() {
    var hub = new Hub();
    Hub.root.init();

    hub.events.LoadScript.fire("http://localhost:12345/test2.yaml");
}
