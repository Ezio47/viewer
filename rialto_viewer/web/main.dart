// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

import 'dart:core';
import 'rialto.dart';


void main() {
    var hub = new Hub();

    //OgcDocumentTests.test();

    try {
        hub.commands.loadScript("http://localhost:12345/file/test.yaml");
    } catch(e) {
        Hub.error("Top-level exception caught", object: e);
    }
}
