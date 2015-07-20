// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend.private;

///
/// Interface to the viewshed analysis, via WPF
///
class Viewshedder {

  /// Starts an asynchronous job to run the viewshed analysis via WPS
  ///
  /// Invokes the general WPS execution function to starts an asynchronous
  /// WPS job to run the viewshed analysis using the given observer
  /// position and radius.
  static void callWps(RialtoBackend backend, double obsLon, double obsLat, double radius) {
    var process = new WpsProcess(backend.wps, "groovy:wpsviewshed");

    var inputs = new Map<String, dynamic>();
    WpsProcessParam param;

    param = new WpsProcessParam("obsLat", WpsProcessParamDataType.double);
    process.inputs.add(param);

    param = new WpsProcessParam("obsLon", WpsProcessParamDataType.double);
    process.inputs.add(param);
    inputs["obsLon"] = obsLon;

    param = new WpsProcessParam("fovStart", WpsProcessParamDataType.double);
    process.inputs.add(param);
    inputs["fovStart"] = 0.0;

    param = new WpsProcessParam("fovEnd", WpsProcessParamDataType.double);
    process.inputs.add(param);
    inputs["fovEnd"] = 360.0;

    param = new WpsProcessParam("eyeHeight", WpsProcessParamDataType.double);
    process.inputs.add(param);
    inputs["eyeHeight"] = 1.5;

    param = new WpsProcessParam("radius", WpsProcessParamDataType.double);
    process.inputs.add(param);
    inputs["radius"] = radius;

    param = new WpsProcessParam("inputDem", WpsProcessParamDataType.string);
    process.inputs.add(param);
    inputs["inputDem"] = "N48W114.hgt";

    param = new WpsProcessParam("outputUrl", WpsProcessParamDataType.string);
    process.outputs.add(param);

    var yes = (WpsJob job, Map<String, dynamic> results) {
      OgcExecuteResponseDocument_54 ogcDoc = job.responseDocument;
      RialtoBackend.log(ogcDoc.dump(0));
      var url = results["outputUrl"];
      RialtoBackend.log("SUCCESS: $url");

      var layerName = "viewshed-${job.id}";
      Map layerOptions = {
        "type": "tms_imagery",
        "url": url,
        "gdal2Tiles": true,
        "maximumLevel": 12,
        //"alpha": 0.5
      };
      backend.commands.addLayer(layerName, layerOptions).then((_) {
        //Hub.log("layer added!");
      });
    };

    backend.commands.wpsExecuteProcess(process, inputs, successHandler: yes);
  }
}

/****
 Notes on the command line tool invocation:

    double obsLat, obsLon;

    // --fov <start> <end>
    // Optional arguments specifying the field-of-view
    // boundary azimuths (in degrees). By default, a 360 deg
    // FOV is computed. The arc is taken clockwise from start
    // to end, so for a FOV of 225 deg from W, through N to
    // SE, start=270 and end=135
    double fovStart = 0.0;
    double fovEnd = 360.0;

    // --hgt-of-eye <meters>
    // Specifies the observers height-of-eye above the
    // terrain in meters.
    double heightOfEye = 1.5;

    // --radius <meters>
    // Specifies max visibility in meters. Required unless
    // --size is specified. This option constrains output to
    // a circle, similar to a radar display
    double radius;

    // --gsd <meters>          Specifies output GSD in meters. Defaults to the same
    //                         resolution as input DEM.
    //                            ** not supported **
    //
    //--input-dem <filename>  Specifies the input DEM filename. If none provided,
    //                        the elevation database is referenced as specified in
    //                        prefs file
    //                          ** used by the server script **
    //
    // --lut <filename>        Specifies the optional lookup table filename
    //                        for mapping the single-band output image to an RGB. The
    //                        LUT provided is in the ossimIndexToRgbLutFilter format
    //                        and must handle the three output viewshed values (see
    //                        --values option).
    //                            ** not supported **
    //
    // --reticle <pixels>      Specifies the size of the reticle at the
    //                        observer location in pixels from the center (i.e., the
    //                        radius of the reticle). Defaults to 2. A value of 0
    //                        hides the reticle. See --values option for setting
    //                        reticle color.
    //                           ** hard-coded to 0 **
    //
    // --size <int>            Instead of a visibility radius, directly specifies the
    //                        dimensions of the output product in pixels (output is
    //                        square). Required unless --radius is specified.
    //                            ** not supported **
    //
    // --summary               Causes a product summary to be output to the console.
    //                          ** used by the server script **
    //
    //--values <int int int>  Specifies the pixel values (0-255) for the visible,
    //                        hidden and reticle pixels, respectively. Defaults to
    //                        visible=null (0), hidden=128, and observer position
    //                        reticle is highlighted with 255.
    //                            ** not supported **
    //
    // output-image-file          ** used by thge server script **
****/
