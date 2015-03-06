// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class ViewshedController implements IController {
    Hub _hub;
    bool isRunning;

    Cartographic3 point1;
    Cartographic3 point2;

    ViewshedController() {
        _hub = Hub.root;
        isRunning = false;

        _hub.modeController.register(this, ModeDataCodes.viewshed);

        _hub.events.MouseMove.subscribe(_handleMouseMove);
        _hub.events.MouseDown.subscribe(_handleMouseDown);
        _hub.events.MouseUp.subscribe(_handleMouseUp);
    }

    void startMode() {
        point1 = point2 = null;
    }

    void endMode() {
    }

    void _handleMouseMove(MouseData data) {
    }

    void _handleMouseDown(MouseData data) {
        if (!isRunning) return;

        assert(isRunning);

        if (point1 == null) {

            point1 = _hub.cesium.getMouseCoordinates(data.x, data.y);
            if (point1 == null) return;

        } else if (point2 == null) {
            point2 = _hub.cesium.getMouseCoordinates(data.x, data.y);
            if (point2 == null) return;

        } else {
            // already have point, do nothing
        }
    }

    void _handleMouseUp(MouseData data) {
        if (!isRunning) return;

        if (point1 == null || point2 == null) {
            return;
        }

        double radius =
                _hub.cesium.cartographicDistance(point1.longitude, point1.latitude, point2.longitude, point2.latitude);

        log("viewshed center: ${Utils.toString_Cartographic3(point1)}");
        log("viewshed radius: $radius");

        new Viewshed(point1, point2);

        _callWps(point1.longitude, point1.latitude, radius);

        point1 = point2 = null;
    }

    void _callWps(double obsLon, double obsLat, double radius) {
        var params = new List(3);
        params[0] = "groovy:wpsviewshed";
        params[1] = {
            "obsLat": obsLat,
            "obsLon": obsLon,
            "fovStart": 0.0,
            "fovEnd": 360.0,
            "eyeHeight": 1.5,
            "radius": radius,
            "inputDem": "foobarbaz.tif",
            "serverInputPath": "/Users/mgerlek/work/dev/tuple/data/wps-scratch/inputs",
            "serverOutputPath": "/Users/mgerlek/work/dev/tuple/data/wps-scratch/outputs",
            "serverOutputUrl": "http://localhost:12345/file/wps-scratch/outputs",
        };
        params[2] = ["outputUrl", "stdoutText", "stderrText"];

        var yes = (WpsJob job) {
            OgcExecuteResponseDocument_54 ogcDoc = job.responseDocument;
            log(ogcDoc.dump(0));
            var url = ogcDoc.getProcessOutput("outputUrl");
            log("SUCCESS: $url");

            var layerData = new LayerData("viewshed", {
                "type": "tms_imagery",
                "url": url,
                "gdal2Tiles": true,
                "maximumLevel": 12
            });
            _hub.commands.addLayer(layerData).then((_) => log("layer added!"));
        };

        var no = (WpsJob job) {
            log("FAILURE");
            assert(job.responseDocument != null || job.exceptionTexts != null);
            if (job.responseDocument != null) {
                log(job.responseDocument.dump(0));
            }
            if (job.exceptionTexts != null) {
                log(job.exceptionTexts);
            }
        };

        var time = (WpsJob job) {
            Hub.error("wps request timed out!");
        };

        var data = new WpsExecuteProcessData(params, successHandler: yes, errorHandler: no, timeoutHandler: time);
        _hub.commands.wpsExecuteProcess(data);
    }
}

class Viewshed {
    ViewshedShape shape;
    Cartographic3 _point1;
    Cartographic3 _point2;

    Viewshed(Cartographic3 point1, Cartographic3 point2) {
        _point1 = point1;
        _point2 = point2;

        _makeShape();
    }

    void _makeShape() {
        shape = new ViewshedShape(_point1, _point2);
    }
}



/****
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
