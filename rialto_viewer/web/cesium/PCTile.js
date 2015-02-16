// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


var tsUNKNOWN = 31;
var tsDOESNOTEXIST = 32;
var tsNOTLOADED = 33;
var tsLOADING = 34;
var tsLOADED = 35;

var csUNKNOWN = 10;
var csEXISTS = 11;
var csDOESNOTEXIST = 12;

var qSW = 20;
var qSE = 21;
var qNE = 22;
var qNW = 23;


var PCTile = function PCTile(tree, level, x, y) {
    "use strict";

    this._tree = tree;
    this._header = tree.header;

    this._level = level;
    this._x = x;
    this._y = y;

    this.buffer = null;

    this.state = tsNOTLOADED;

    this.swState = csUNKNOWN;
    this.seState = csUNKNOWN;
    this.nwState = csUNKNOWN;
    this.neState = csUNKNOWN;

    this.sw = undefined;
    this.se = undefined;
    this.nw = undefined;
    this.ne = undefined;

    this.primitive = undefined;

    this.url = this._tree.provider.url + "/" + level + "/" + x + "/" + y + ".ria";

    this.dimensions = undefined; // list of arrays of dimension data
};


Object.defineProperties(PCTile.prototype, {
    level : {
        get : function () {
            "use strict";
            return this._level;
        }
    },
    x : {
        get : function () {
            "use strict";
            return this._x;
        }
    },
    y : {
        get : function () {
            "use strict";
            return this._y;
        }
    }
});


// Dataview is an array-of-structs: x0, y0, z0, t0, x1, y1, ...
// Create an array of all the elements from one of the struct fields
PCTile.prototype._extractDimensionArray = function (dataview, datatype, offset, stride, len) {
    "use strict";

    var dst, dstIndex, dvIndex;

    switch (datatype) {
    case "uint8_t":
        dst = new Uint8Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getUint8(dvIndex);
        }
        break;
    case "int8_t":
        dst = new Int8Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getInt8(dvIndex);
        }
        break;
    case "uint16_t":
        dst = new Uint16Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getUint16(dvIndex, true);
        }
        break;
    case "int16_t":
        dst = new Int16Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getInt16(dvIndex, true);
        }
        break;
    case "uint32_t":
        dst = new Uint32Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getUint32(dvIndex, true);
        }
        break;
    case "int32_t":
        dst = new Int32Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getInt32(dvIndex, true);
        }
        break;
    case "uint64_t":
        dst = new Uint64Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getUint64(dvIndex, true);
        }
        break;
    case "int64_t":
        dst = new Int64Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getInt64(dvIndex, true);
        }
        break;
    case "float":
        dst = new Float32Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getFloat32(dvIndex, true);
        }
        break;
    case "double":
        dst = new Float64Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getFloat64(dvIndex, true);
        }
        break;
    default:
        assert(false, 70);
        break;
    }
    return dst;
};


PCTile.prototype._buildDimensionArrays = function (dataview, numBytes) {
    "use strict";

    var headerDims = this._header.dimensions;
    var i;
    var datatype,
        offset,
        stride,
        name,
        v;

    if (numBytes == 0) {
        this.numPoints = 0;
    } else {
        this.numPoints = numBytes / this._tree.provider.pointSizeInBytes;
        assert(this.numPoints * this._tree.provider.pointSizeInBytes == numBytes, 71);
    }

    this.dimensions = [];

    //console.log("num points in tile: " + this.numPoints);

    for (i = 0; i < headerDims.length; i += 1) {
        datatype = headerDims[i].datatype;
        offset = headerDims[i].offset;
        name = headerDims[i].name;
        stride = this._tree.provider.pointSizeInBytes;

        if (this.numPoints == 0) {
            v = null;
        } else {
            v = this._extractDimensionArray(dataview, datatype, offset, stride, this.numPoints);
        }
        this.dimensions.push(v);
    }
};


PCTile.prototype._makeChildren = function (mask) {
    //console.log("mask is " + mask);

    this.sw = null;
    this.se = null;
    this.nw = null;
    this.ne = null;

    this.swState = csDOESNOTEXIST;
    this.seState = csDOESNOTEXIST;
    this.nwState = csDOESNOTEXIST;
    this.neState = csDOESNOTEXIST;

    var level = this.level;
    var x = this.x;
    var y = this.y;

    if ((mask & 1) == 1) {
        this.sw = this._tree.createPCTile(level + 1, 2 * x, 2 * y + 1);
        this.swState = csEXISTS;
    }
    if ((mask & 2) == 2) {
        this.se = this._tree.createPCTile(level + 1, 2 * x + 1, 2 * y + 1);
        this.seState = csEXISTS;
    }
    if ((mask & 4) == 4) {
        this.ne = this._tree.createPCTile(level + 1, 2 * x + 1, 2 * y);
        this.neState = csEXISTS;
    }
    if ((mask & 8) == 8) {
        this.nw = this._tree.createPCTile(level + 1, 2 * x, 2 * y);
        this.nwState = csEXISTS;
    }
}


PCTile.prototype.addTileData = function (buffer) {
    "use strict";

    //console.log("addding " + t.level + t.x + t.y);

    var level = this.level;
    var x = this.x;
    var y = this.y;

    var bytes = new Uint8Array(buffer);
    var buflen = bytes.length;
    //console.log("buflen=" + buflen);

    if (bytes.length > 1) {
        var dv = new DataView(buffer, 0, buflen - 1);
        this._buildDimensionArrays(dv, buflen - 1);
    } else {
        this._buildDimensionArrays(null, 0);
    }

    // this is the array used to colorize each point
    var rgba = new Uint8Array(this.numPoints * 4);
    var i;
    for (i = 0; i < this.numPoints * 4; i += 1) {
        rgba[i] = 255;
    }
    this.dimensions.push(rgba);

    var mask = bytes[bytes.length - 1];
    this._makeChildren(mask);
};


PCTile.prototype.loadTileData = function () {
    "use strict";

    //console.log("loading " + this.level + this.x + this.y);

    assert(this.state == tsNOTLOADED, 2);
    this.state = tsLOADING;

    var thisTile = this;

    Cesium.loadBlob(this.url).then(function (blob) {
        //console.log("got blob:" + blob.size);

        var reader = new FileReader();
        reader.addEventListener("loadend", function () {
            var arraybuffer = reader.result;
            thisTile.addTileData(arraybuffer);
            thisTile.primitive = thisTile.createPrimitive(thisTile.numPoints, thisTile.dimensions);
            thisTile.state = tsLOADED;
        });
        reader.readAsArrayBuffer(blob);

    }).otherwise(function () {
        //console.log("FAIL getting blob: " + this.url);
    });
};


// taken from Cartesian3.fromDegreesArrayHeights
PCTile.prototype.Cartesian3_fromDegreesArrayHeights_merge = function (x, y, z, cnt, ellipsoid) {
    "use strict";

    assert(cnt==this.numPoints, 66);

    var xyz = new Float64Array(cnt * 3);

    var i;
    var lon, lat, alt, result;
    for (i = 0; i < cnt; i++) {
        lon = Cesium.Math.toRadians(x[i]);
        lat = Cesium.Math.toRadians(y[i]);
        alt = z[i];

        result = Cesium.Cartesian3.fromRadians(lon, lat, alt, ellipsoid);

        xyz[i*3] = result.x;
        xyz[i*3+1] = result.y;
        xyz[i*3+2] = result.z;
    }

    return xyz;
};


// x,y,z as F64 arrays
// rgba as U8 array
PCTile.prototype.createPrimitive = function (cnt, dims) {
    "use strict";

    if (cnt == 0) {
        return null;
    }

    // TODO: assumes x,y,z are first and rgba is last
    var x = dims[0];
    var y = dims[1];
    var z = dims[2];
    var rgba = dims[dims.length-1];

    var xyz = this.Cartesian3_fromDegreesArrayHeights_merge(x, y, z, cnt);

    assert(this.numPoints == cnt, 39);
    assert(xyz.length == cnt * 3, 40);
    assert(rgba.length == cnt * 4, 41);

    var pointInstance = new Cesium.GeometryInstance({
        geometry : new Cesium.PointGeometry({
            positionsTypedArray: xyz,
            colorsTypedArray: rgba
        }),
        id : 'point'
    });

    var prim = new Cesium.Primitive({
        geometryInstances : [pointInstance],
        appearance : new Cesium.PointAppearance()
    });

    return prim;
};
