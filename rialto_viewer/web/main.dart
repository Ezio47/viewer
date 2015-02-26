// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

import 'dart:core';
import 'rialto.dart';

final Map tests = {
    0: "test.yaml",
    1: "unittests/base_imagery_arcgis.yaml",
    2: "unittests/base_imagery_bing_aerial.yaml",
    3: "unittests/base_imagery_bing_aeriallabels.yaml",
    //4: "unittests/base_imagery_bing_collinsbart.yaml",
    //5: "unittests/base_imagery_bing_ordnancesurvey.yaml",
    6: "unittests/base_imagery_bing_road.yaml",
    7: "unittests/base_imagery_osm.yaml",
    //8: "unittests/base_terrain_arcgis.yaml",
    9: "unittests/base_terrain_cesium_small.yaml",
    10: "unittests/base_terrain_cesium_stk.yaml",
    11: "unittests/base_terrain_ellipsoid.yaml",
    12: "unittests/base_terrain_vrtheworld.yaml",
    13: "unittests/geojson_1.yaml",
    14: "unittests/geojson_2.yaml",
    15: "unittests/geojson_3.yaml",
    16: "unittests/pointcloud.yaml",
    17: "unittests/terrain.yaml",
    18: "unittests/wps.yaml",
};


void main() {
    var hub = new Hub();

    //OgcDocumentTests.test();

    try {
        String s = "http://localhost:12345/file/" + tests[0];
        var uri = Uri.parse(s);
        hub.commands.loadScript(uri);
    } catch (e) {
        Hub.error("Top-level exception caught", object: e);
    }
}
