// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


var PointCloudTile = function PointCloudTile(provider, level, x, y) {
    this._provider = provider;
    this._x = x;
    this._y = y;
    this._level = level;

    this._primitive = undefined;
    this.url = this._provider._url + "/" + level + "/" + x + "/" + y + ".ria";
    this.dimensions = undefined; // list of arrays of dimension data
    this.sw = false;
    this.se = false;
    this.nw = false;
    this.ne = false;
    this._childTileMask = undefined;

    this._ready = false;
}


Object.defineProperties(PointCloudTile.prototype, {
    ready : {
        get : function () {
            "use strict";
            //mylog("ready check" + this._ready);
            return this._ready;
        }
    },
    primitive : {
        get : function () {
            "use strict";
            //mylog("ready check" + this._ready);
            return this._primitive;
        }
    },
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


// sets this.ready when done
PointCloudTile.prototype.load = function() {
   "use strict";

    //mylog("loading " + tilename(this));

    var that = this;

    Cesium.loadBlob(this.url).then(function (blob) {
        //mylog("got blob:" + blob.size);

        var reader = new FileReader();
        reader.addEventListener("loadend", function () {
            var buffer = reader.result;
            that._loadFromBuffer(buffer);
            that.colorize();
            that._primitive = that.createPrimitive(that.numPoints, that.dimensions);
            that._ready = true;
            //mylog("ready: " + tilename(that));
        });
        reader.readAsArrayBuffer(blob);

    }).otherwise(function () {
        myerror("Failed to read point cloud tile: " + this.url);
    });
}


PointCloudTile.prototype._loadFromBuffer = function (buffer) {
    "use strict";

    var level = this.level;
    var x = this.x;
    var y = this.y;

    var bytes = new Uint8Array(buffer);
    var numBytes = bytes.length;
    //mylog("numBytes=" + numBytes);

    if (numBytes > 1) {
        var dv = new DataView(buffer, 0, numBytes - 1);
        this._createDimensionArrays(dv, numBytes - 1);
    } else {
        this._createDimensionArrays(null, 0);
    }

    var mask = bytes[numBytes - 1];
    this._setChildren(mask);
};


PointCloudTile.prototype._createDimensionArrays = function (dataview, numBytes) {
    "use strict";

    var headerDims = this._provider.header.dimensions;
    var i;
    var datatype,
        offset,
        stride,
        name,
        v;

    var pointSize = this._provider.header.pointSizeInBytes;

    if (numBytes == 0) {
        this.numPoints = 0;
    } else {
        this.numPoints = numBytes / pointSize;
        myassert(this.numPoints * pointSize == numBytes, 71);
    }

    this.dimensions = {};

    //mylog("num points in tile: " + this.numPoints);

    for (i = 0; i < headerDims.length; i += 1) {
        datatype = headerDims[i].datatype;
        offset = headerDims[i].offset;
        name = headerDims[i].name;
        stride = pointSize;

        if (this.numPoints == 0) {
            v = null;
        } else {
            v = this._extractDimensionArray(dataview, datatype, offset, stride, this.numPoints);
        }
        this.dimensions[name] = v;
    }

   // this is the array used to colorize each point
    var rgba = new Uint8Array(this.numPoints * 4);
    for (i = 0; i < this.numPoints * 4; i += 1) {
        rgba[i] = 255;
    }
    name = "rgba";
    this.dimensions[name] = rgba;
};


// Dataview is an array-of-structs: x0, y0, z0, t0, x1, y1, ...
// Create an array of all the elements from one of the struct fields
PointCloudTile.prototype._extractDimensionArray = function (dataview, datatype, offset, stride, len) {
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
        myassert(false, 70);
        break;
    }
    return dst;
};

PointCloudTile.prototype._setChildren = function (mask) {
    //mylog("mask is " + mask);

    this._childTileMask = mask;

    var level = this.level;
    var x = this.x;
    var y = this.y;

    if ((mask & 1) == 1) {
        // (level + 1, 2 * x, 2 * y + 1);
        this.sw = true;
    }
    if ((mask & 2) == 2) {
        // (level + 1, 2 * x + 1, 2 * y + 1);
        this.se = true;
    }
    if ((mask & 4) == 4) {
        // (level + 1, 2 * x + 1, 2 * y);
        this.ne = true;
    }
    if ((mask & 8) == 8) {
        // (level + 1, 2 * x, 2 * y);
        this.nw = true;
    }

    myassert(this.isChildAvailable(x, y, x*2, y*2+1) == this.sw, "SW");
    myassert(this.isChildAvailable(x, y, x*2+1, y*2+1) == this.se, "SE");
    myassert(this.isChildAvailable(x, y, x*2+1, y*2) == this.ne, "NE");
    myassert(this.isChildAvailable(x, y, x*2, y*2) == this.nw, "NW");

    //mylog("children of " + tilename(this) + ": " + this.sw + this.se + this.ne + this.nw);
}


// taken from Cartesian3.fromDegreesArrayHeights
PointCloudTile.prototype.Cartesian3_fromDegreesArrayHeights_merge = function (x, y, z, cnt, ellipsoid) {
    "use strict";

    myassert(cnt==this.numPoints, 66);

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
PointCloudTile.prototype.createPrimitive = function (cnt, dims) {
    "use strict";

    if (cnt == 0) {
        return null;
    }

    var x = dims["X"];
    var y = dims["Y"];
    var z = dims["Z"];
    var rgba = dims["rgba"];

    var xyz = this.Cartesian3_fromDegreesArrayHeights_merge(x, y, z, cnt);

    myassert(this.numPoints == cnt, 39);
    myassert(xyz.length == cnt * 3, 40);
    myassert(rgba.length == cnt * 4, 41);

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


PointCloudTile.prototype.colorize = function () {

    var headerDims = this._provider.header.dimensions;
    var min, max;
    for (var i=0; i<headerDims.length; i++) {
        if (headerDims[i].name == this._provider.colorizeDimension) {
            min = headerDims[i].min;
            max = headerDims[i].max;
            break;
        }
    }

    var nam = this._provider.colorizeDimension;
    var dataArray = this.dimensions[nam];
    var rgba = "rgba";
    var rgbaArray = this.dimensions[rgba];

    doColorize(this._provider.rampName, dataArray, this.numPoints, min, max, rgbaArray);
};


PointCloudTile.prototype.isChildAvailable = function(thisX, thisY, childX, childY) {

    var x = thisX;
    var y = thisY;

    if (childX == x*2 && childY == y*2+1) return this.sw;
    if (childX == x*2+1 && childY == y*2+1) return this.se;
    if (childX == x*2+1 && childY == y*2) return this.ne;
    if (childX == x*2 && childY == y*2) return this.nw;
    return false;

        var bitNumber = 2; // northwest child
        if (childX !== thisX * 2) {
            ++bitNumber; // east child
        }
        if (childY !== thisY * 2) {
            bitNumber -= 2; // south child
        }

        return (this._childTileMask & (1 << bitNumber)) !== 0;
};


var tilename = function(tile) {
    var s = "[" + tile.level + "," + tile.x + "," + tile.y + "]";
    return s;
};
