// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

import 'dart:core';
import 'rialto.dart';

final Map tests = {
    0: "test.yaml",
    1: "unittests/base_imagery_arcgis.yaml",                // world, arcgis base image
    2: "unittests/base_imagery_bing_aerial.yaml",           // world, bing base image
    3: "unittests/base_imagery_bing_aeriallabels.yaml",     // world, bing base image with labels
    //"unittests/base_imagery_bing_collinsbart.yaml",
    //"unittests/base_imagery_bing_ordnancesurvey.yaml",
    4: "unittests/base_imagery_bing_road.yaml",             // world, bing base vectors
    5: "unittests/base_imagery_osm.yaml",                   // world, osm base vectors
    //"unittests/base_terrain_arcgis.yaml",
    6: "unittests/base_terrain_cesium_small.yaml",          // grand canyon, base image with terrain
    7: "unittests/base_terrain_cesium_stk.yaml",           // grand canyon, base image with terrain
    8: "unittests/base_terrain_ellipsoid.yaml",            // grand canyon, base image with flat terrain
    9: "unittests/base_terrain_vrtheworld.yaml",           // grand canyon, base image with terrain
    10: "unittests/geojson_1.yaml",                         // two shapes + serp cloud
    11: "unittests/geojson_2.yaml",                         // giraffe + serp cloud
    12: "unittests/geojson_3.yaml",                         // two shape & giraffe + serp cloud
    13: "unittests/imagery_mixins.yaml",                    // 5 different fans, only 4 visible
    14: "unittests/pointcloud_1.yaml",                      // just serp cloud
    15: "unittests/pointcloud_2.yaml",                      // serp cloud on bing base imagery
    16: "unittests/single_imagery.yaml",                    // world + fan
    17: "unittests/terrain.yaml",                           // grand canyon, base imagery with terrain
    18: "unittests/wms_imagery.yaml",                       // just dots on white world
    19: "unittests/wps.yaml",                               // just pointcloud, plus output to console
    20: "unittests/wtms_imagery.yaml",                      // world at night
};


void main() {
    var hub = new Hub();

    try {
        String s = "http://localhost:12345/file/" + tests[0];
        var uri = Uri.parse(s);
        hub.commands.loadScript(uri);
    } catch (e) {
        Hub.error("Top-level exception caught", object: e);
    }
}
