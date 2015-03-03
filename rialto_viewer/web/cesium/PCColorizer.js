// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


// each ramp is a list of Stops
// a Stop is a list with two elements, the stop point and a color-triplet
var colorRamps = {
    //"native": [],
    "Blues": [[0.00, [247, 251, 255]], [0.13, [222, 235, 247]], [0.26, [198, 219, 239]], [0.39, [158, 202, 225]], [0.52, [107, 174, 214]], [0.65, [66, 146, 198]], [0.78, [33, 113, 181]], [0.90, [8, 81, 156]], [1.00, [8, 48, 107]]],
    "Brown-Blue-Green": [[0.00, [166, 97, 26]], [0.25, [223, 194, 125]], [0.5, [245, 245, 245]], [0.75, [128, 205, 193]], [1.00, [1, 133, 113]]],
    "Blue-Green": [[0.00, [237, 248, 251]], [0.25, [178, 226, 226]], [0.50, [102, 194, 164]], [0.75, [44, 162, 95]], [1.00, [0, 109, 44]]],
    "Blue-Purple": [[0.00, [237, 248, 251]], [0.25, [179, 205, 227]], [0.50, [140, 150, 198]], [0.75, [136, 86, 167]], [1.00, [129, 15, 124]]],
    "Green-Blue": [[0.00, [240, 249, 232]], [0.25, [186, 228, 188]], [0.50, [123, 204, 196]], [0.75, [67, 162, 202]], [1.00, [8, 104, 172]]],
    "Greens": [[0.00, [247, 252, 245]], [0.13, [229, 245, 224]], [0.26, [199, 233, 192]], [0.39, [161, 217, 155]], [0.52, [116, 196, 118]], [0.65, [65, 171, 93]], [0.78, [35, 139, 69]], [0.90, [0, 109, 44]], [1.00, [0, 68, 27]]],
    "Greys": [[0.00, [250, 250, 250]], [1.00, [5, 5, 5]]],
    "Orange-Red": [[0.00, [254, 240, 217]], [0.25, [253, 204, 138]], [0.50, [252, 141, 89]], [0.75, [227, 74, 51]], [1.00, [179, 0, 0]]],
    "Oranges": [[0.00, [255, 245, 235]], [0.13, [254, 230, 206]], [0.26, [253, 208, 162]], [0.39, [253, 174, 107]], [0.52, [253, 141, 60]], [0.65, [241, 105, 19]], [0.78, [217, 72, 1]], [0.90, [166, 54, 3]], [1.00, [127, 39, 4]]],
    "Pink-Red-Green": [[0.00, [123, 50, 148]], [0.25, [194, 165, 207]], [0.50, [247, 247, 247]], [0.75, [166, 219, 160]], [1.00, [0, 136, 55]]],
    "Pink-Yellow-Green": [[0.00, [208, 28, 139]], [0.25, [241, 182, 218]], [0.50, [247, 247, 247]], [0.75, [184, 225, 134]], [1.00, [77, 172, 38]]],
    "Purple-Blue": [[0.00, [241, 238, 246]], [0.25, [189, 201, 225]], [0.50, [116, 169, 207]], [0.75, [43, 140, 190]], [1.00, [4, 90, 141]]],
    "Purple-Blue-Green": [[0.00, [246, 239, 247]], [0.25, [189, 201, 225]], [0.50, [103, 169, 207]], [0.75, [28, 144, 153]], [1.00, [1, 108, 89]]],
    "Purple-Orange": [[0.00, [230, 97, 1]], [0.25, [253, 184, 99]], [0.50, [247, 247, 247]], [0.75, [178, 171, 210]], [1.00, [94, 60, 153]]],
    "Purple-Red": [[0.00, [241, 238, 246]], [0.25, [215, 181, 216]], [0.50, [223, 101, 176]], [0.75, [221, 28, 119]], [1.00, [152, 0, 67]]],
    "Purples": [[0.00, [252, 251, 253]], [0.13, [239, 237, 245]], [0.26, [218, 218, 235]], [0.39, [188, 189, 220]], [0.52, [158, 154, 200]], [0.65, [128, 125, 186]], [0.75, [106, 81, 163]], [0.90, [84, 39, 143]], [1.00, [63, 0, 125]]],
    "Red-Blue": [[0.00, [202, 0, 32]], [0.25, [244, 165, 130]], [0.50, [247, 247, 247]], [0.75, [146, 197, 222]], [1.00, [5, 113, 176]]],
    "Red-Grey": [[0.00, [202, 0, 32]], [0.25, [244, 165, 130]], [0.50, [255, 255, 255]], [0.75, [186, 186, 186]], [1.00, [64, 64, 64]]],
    "Red-Purple": [[0.00, [254, 235, 226]], [0.25, [251, 180, 185]], [0.50, [247, 104, 161]], [0.75, [197, 27, 138]], [1.00, [122, 1, 119]]],
    "Red-Yellow-Blue": [[0.00, [215, 25, 28]], [0.25, [253, 174, 97]], [0.50, [255, 255, 191]], [0.75, [171, 217, 233]], [1.00, [44, 123, 182]]],
    "RdYlGn": [[0.00, [215, 25, 28]], [0.25, [253, 174, 97]], [0.50, [255, 255, 192]], [0.75, [166, 217, 106]], [1.00, [26, 150, 65]]],
    "Reds": [[0.00, [255, 245, 240]], [0.13, [254, 224, 210]], [0.26, [252, 187, 161]], [0.39, [252, 146, 114]], [0.52, [251, 106, 74]], [0.65, [239, 59, 44]], [0.78, [203, 24, 29]], [0.90, [165, 15, 21]], [1.00, [103, 0, 13]]],
    "Spectral": [[0.00, [215, 25, 28]], [0.25, [253, 174, 97]], [0.50, [255, 255, 191]], [0.75, [171, 221, 164]], [1.00, [43, 131, 186]]],
    "Yellow-Green": [[0.00, [255, 255, 204]], [0.25, [194, 230, 153]], [0.50, [120, 198, 121]], [0.75, [49, 163, 84]], [1.00, [0, 104, 55]]],
    "Yellow-Green-Blue": [[0.00, [255, 255, 204]], [0.25, [161, 218, 180]], [0.50, [65, 182, 196]], [0.75, [44, 127, 184]], [1.00, [37, 52, 148]]],
    "Yellow-Orange-Brown": [[0.00, [255, 255, 212]], [0.25, [254, 217, 142]], [0.50, [254, 153, 41]], [0.75, [217, 95, 14]], [1.00, [153, 52, 4]]],
    "Yellow-Orange-Red": [[0.00, [255, 255, 178]], [0.25, [254, 204, 92]], [0.50, [253, 141, 60]], [0.75, [240, 59, 32]], [1.00, [189, 0, 38]]]
};


// returns a color triplet
var _interpolateColorRamp = function (z, startRange, endRange, startColor, endColor) {
    'use strict';

    var scale = (z - startRange) / (endRange - startRange);
    myassert(scale >= 0.0 && scale <= 1.0);

    var r = scale * (endColor[0] - startColor[0]) + startColor[0];
    var g = scale * (endColor[1] - startColor[1]) + startColor[1];
    var b = scale * (endColor[2] - startColor[2]) + startColor[2];
    myassert(r >= 0.0 && r <= 255.0);
    myassert(g >= 0.0 && g <= 255.0);
    myassert(b >= 0.0 && b <= 255.0);

    return [r, g, b];
};


// rampType is string
// dataArray is a typed array
// zmin, zmax are doubles
// rgbaArray is Uint8Array of r,g,b,a

var doColorize = function (rampName, dataArray, numPoints, zmin, zmax, rgbaArray) {
    'use strict';

    myassert(rampName != "native");
    /*if (ramp == "native") {
        mylog(tile.data.keys);
        if (!tile.data.containsKey("Red") || !tile.data.containsKey("Green") || !tile.data.containsKey("Blue")) {
            Hub.error("Native colorization not supported for point clouds without RGB data");
            return null;
        }
        var rlist = tile.data["Red"];
        var glist = tile.data["Green"];
        var blist = tile.data["Blue"];
        myassert(rlist is Uint8List);
        myassert(glist is Uint8List);
        myassert(blist is Uint8List);

        for (int i = 0; i < tile.numPointsInTile; i++) {
            rgba[i * 4 + 0] = rlist[i];
            rgba[i * 4 + 1] = glist[i];
            rgba[i * 4 + 2] = blist[i];
            rgba[i * 4 + 3] = 255;
        }
        return rgba;
    }*/

    var stops = colorRamps[rampName];

    var zLen = zmax - zmin;

    var i;
    var z;
    var scaledZ;
    var startRange, endRange;
    var result;
    var s;

    for (i = 0; i < numPoints; i += 1) {
        z = dataArray[i];

        // handle FP math
        if (z < zmin) {
            z = zmin;
        } else if (z > zmax) {
            z = zmax;
        }

        scaledZ = (zLen == 0.0) ? 0.0 : (z - zmin) / zLen;

        // handle FP math
        if (scaledZ < 0.0) {
            scaledZ = 0.0;
        }
        if (scaledZ > 1.0) {
            scaledZ = 1.0;
        }

        myassert(stops.length >= 2);
        myassert(stops[0][0] == 0.0);
        myassert(stops[stops.length - 1][0] == 1.0);

        startRange = stops[0][0];

        result = null; // TODO: don't make new object for each point

        for (s = 1; s < stops.length; s += 1) {
            endRange = stops[s][0];

            if (scaledZ >= startRange && scaledZ <= endRange) {
                result = _interpolateColorRamp(scaledZ, startRange, endRange, stops[s - 1][1], stops[s][1]);
                break;
            }

            startRange = endRange;
        }
        myassert(result != null);

        myassert(result[0] >= 0 && result[0] <= 255);
        myassert(result[1] >= 0 && result[1] <= 255);
        myassert(result[2] >= 0 && result[2] <= 255);
        rgbaArray[i * 4] = result[0];
        rgbaArray[i * 4 + 1] = result[1];
        rgbaArray[i * 4 + 2] = result[2];
        rgbaArray[i * 4 + 3] = 255;
    }
};
