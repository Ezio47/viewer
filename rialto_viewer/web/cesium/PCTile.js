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


PCTile.prototype._makeFromStridedSlice = function (dataview, datatype, offset, stride, len) {
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
            dst[dstIndex] = dataview.getUint16(dvIndex);
        }
        break;
    case "int16_t":
        dst = new Int16Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getInt16(dvIndex);
        }
        break;
    case "uint32_t":
        dst = new Uint32Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getUint32(dvIndex);
        }
        break;
    case "int32_t":
        dst = new Int32Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getInt32(dvIndex);
        }
        break;
    case "uint64_t":
        dst = new Uint64Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getUint64(dvIndex);
        }
        break;
    case "int64_t":
        dst = new Int64Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getInt64(dvIndex);
        }
        break;
    case "float":
        dst = new Float32Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getFloat32(dvIndex);
        }
        break;
    case "double":
        dst = new Float64Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getFloat64(dvIndex);
        }
        break;
    default:
        break;
    }
    return dst;
};


PCTile.prototype._setDimArrays = function (buffer, bufferLength) {
    "use strict";

    var dims = this._header.dimensions,
        dataview = new DataView(buffer);
    var i;
    var datatype,
        offset,
        stride,
        name,
        v;

    this.numPoints = bufferLength / this._tree.provider.pointSizeInBytes;

    this.dimensions = {};

//    console.log("num points in tile: " + this.numPoints);

    for (i = 0; i < dims.length; i += 1) {
        datatype = dims[i].datatype;
        offset = dims[i].offset;
        name = dims[i].name;
        stride = this._tree.provider.pointSizeInBytes;

        v = this._makeFromStridedSlice(dataview, datatype, offset, stride, this.numPoints);
        if (this.dimensions[name] == undefined) {
            this.dimensions[name] = {};
        }
        this.dimensions[name].data = v;
    }
};


PCTile.prototype.addTileData = function (buffer) {
    "use strict";

    //console.log("addding " + t.level + t.x + t.y);

    var level = this.level;
    var x = this.x;
    var y = this.y;

    var bytes = new Uint8Array(buffer);
    var mask = bytes[bytes.length - 1];
    //console.log("mask is " + mask);

    this.sw = null;
    this.se = null;
    this.nw = null;
    this.ne = null;

    this.swState = csDOESNOTEXIST;
    this.seState = csDOESNOTEXIST;
    this.nwState = csDOESNOTEXIST;
    this.neState = csDOESNOTEXIST;

    if ((mask & 1) == 1) {
        this.sw = this._tree.createTile(level + 1, 2 * x, 2 * y + 1);
        this.swState = csEXISTS;
    }
    if ((mask & 2) == 2) {
        this.se = this._tree.createTile(level + 1, 2 * x + 1, 2 * y + 1);
        this.seState = csEXISTS;
    }
    if ((mask & 4) == 4) {
        this.ne = this._tree.createTile(level + 1, 2 * x + 1, 2 * y);
        this.neState = csEXISTS;
    }
    if ((mask & 8) == 8) {
        this.nw = this._tree.createTile(level + 1, 2 * x, 2 * y);
        this.nwState = csEXISTS;
    }

    this.buffer = buffer;

    this._setDimArrays(buffer, bytes.length - 1);

    var rgba = new Uint8Array(this.numPoints * 4);
    var i;
    for (i = 0; i < this.numPoints * 4; i += 1) {
        rgba[i] = 255;
    }

    if (this.dimensions["rgba"] == undefined) {
        this.dimensions["rgba"] = {};
    }
    this.dimensions["rgba"].data = rgba;
};


PCTile.prototype.loadTileData = function () {
    "use strict";

    //console.log("loading " + this.level + this.x + this.y);

    var url = this._tree.getUrl(this);

    assert(this.state == tsNOTLOADED, 2);
    this.state = tsLOADING;

    var thisTile = this;

    Cesium.loadBlob(url).then(function (blob) {
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
        //console.log("FAIL getting blob: " + url);
    });
};


// taken from Cartesian3.fromDegreesArrayHeights
PCTile.prototype.Cartesian3_fromDegreesArrayHeights_merge = function (x, y, z, cnt, ellipsoid) {
    "use strict";

    console.log(cnt);
    console.log(this.numPoints);
    assert(cnt==this.numPoints, 66);

    var numPoints = x.length;
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

    console.log("cnt=" + cnt);

    if (cnt==22 || cnt==28) {
        for (var i=0; i<cnt; i++) {
            console.log("X" + i + ": " + dims.X.data[i]);
            console.log("Y" + i + ": " + dims.Y.data[i]);
            console.log("Z" + i + ": " + dims.Z.data[i]);
            dims.X.data[i] = 0.0;
            dims.Y.data[i] = 0.0;
            dims.Z.data[i] = 0.0;
            //dims.rgba.data[i] = 0;
        }
    }

    if (cnt == 0) {
        return null;
    }

    var x = new Float64Array(dims.X.data, 0, cnt);
    var y = new Float64Array(dims.Y.data, 0, cnt);
    var z = new Float64Array(dims.Z.data, 0, cnt);
    var rgba = dims.rgba.data;

    var xyz = this.Cartesian3_fromDegreesArrayHeights_merge(x, y, z, cnt);

    //console.log("xyz.len=" + xyz.length);
    //console.log("rgba.len=" + rgba.length);

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
