// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

import 'package:barback/barback.dart';
import 'dart:async';


class InlineCss extends Transformer {

    InlineCss.asPlugin();

    Future<String> getCss(Transform transform) {
        var id = new AssetId("rialto_viewer", "web/viewmodels/elements.css");
        return transform.readInputAsString(id);
    }

    static const String magic = "/*** RIALTO-CSS-GOES-HERE ***/";
    static const String beg = "\n/*--- INLINED CSS STARTS --- */\n";
    static const String end = "\n/*--- INLINED CSS ENDS --- */\n";

    String get allowedExtensions => ".html";

    Future apply(Transform transform) {
        return getCss(transform).then((css) {
            return transform.primaryInput.readAsString().then((content) {
                var id = transform.primaryInput.id;
                final String newContent = content.replaceFirst(magic, beg + css + end);
                //print("--------");
                //print(newContent);
                //print("--------");
                transform.addOutput(new Asset.fromString(id, newContent));
                return;
            });
        });
    }
}
