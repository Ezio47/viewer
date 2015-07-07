// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


import 'dart:async';
import 'dart:html';
import 'frontend/rialto_frontend_library.dart';
import 'backend/rialto_backend_library.dart';


final String demoConfig = """
- layers:
    - bing:
        type: bing_base_imagery
        #style: Road
        style: Aerial
- wps:
    proxy: http://localhost:12346/
    url: http://localhost:8080/geoserver/ows
    description: "la la la"

""";


/// Main entry point for running the viewer
///
/// Called from inside index.html. Creates the viewer, reads in the configuration file, and
/// runs the commands in it to create the layers
void main() {
    // TODO: addErrorListener not yet implemented in Dart SDK...
    //ReceivePort errPort = new ReceivePort();
    //Isolate.current.addErrorListener(errPort.sendPort);
    //errPort.listen((d) => log("bonk: $d"));

    var ui = new RialtoFrontend();

    final params = Uri.parse(window.location.href).queryParameters;
    String configParam = params["config"];

    Future<List<dynamic>> p;

    if (configParam == null) {
        try {
            p = ui.backend.commands.loadScriptFromStringAsync(demoConfig);
        } catch (e) {
            RialtoBackend.error("Top-level exception caught", e);
        }
    } else {
        try {
            final configUri = Uri.parse(configParam);
            p = ui.backend.commands.loadScriptFromUrl(configUri);
        } catch (e) {
            RialtoBackend.error("Top-level exception caught", e);
        }
    }

    // TODO: get ths out of main()
    p.then((list) {
        WpsService wps = ui.backend.wps;
        if (wps != null) {
              for (WpsProcess process in wps.processes.values) {
                    ui.addWpsProcess(process.name);
            };
        }
    });
}


/*
final Map tests = {
    0: "test.yaml",
    1: "unittests/base_imagery_arcgis.yaml", // world, arcgis base image
    2: "unittests/base_imagery_bing_aerial.yaml", // world, bing base image
    3: "unittests/base_imagery_bing_aeriallabels.yaml", // world, bing base image with labels
    //"unittests/base_imagery_bing_collinsbart.yaml",
    //"unittests/base_imagery_bing_ordnancesurvey.yaml",
    4: "unittests/base_imagery_bing_road.yaml", // world, bing base vectors
    5: "unittests/base_imagery_osm.yaml", // world, osm base vectors
    //"unittests/base_terrain_arcgis.yaml",
    6: "unittests/base_terrain_cesium_small.yaml", // grand canyon, base image with terrain
    7: "unittests/base_terrain_cesium_stk.yaml", // grand canyon, base image with terrain
    8: "unittests/base_terrain_ellipsoid.yaml", // grand canyon, base image with flat terrain
    9: "unittests/base_terrain_vrtheworld.yaml", // grand canyon, base image with terrain
    10: "unittests/geojson_1.yaml", // two shapes + serp cloud
    11: "unittests/geojson_2.yaml", // giraffe + serp cloud
    12: "unittests/geojson_3.yaml", // two shape & giraffe + serp cloud
    13: "unittests/imagery_mixins.yaml", // 5 different fans, only 4 visible
    14: "unittests/pointcloud_1.yaml", // just serp cloud
    15: "unittests/pointcloud_2.yaml", // serp cloud on bing base imagery
    16: "unittests/single_imagery.yaml", // world + fan
    17: "unittests/terrain.yaml", // grand canyon, base imagery with terrain
    18: "unittests/wms_imagery.yaml", // just dots on white world
    19: "unittests/wps.yaml", // just pointcloud, plus output to console
    20: "unittests/tms_imagery.yaml", // world at night
};
*/
