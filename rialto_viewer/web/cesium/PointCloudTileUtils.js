// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

var tilename = function(tile) {
    var s = "[" + tile.level + "," + tile.x + "," + tile.y + "]";
    return s;
}


var PPCCProvider = function PPCCProvider(urlarg, colorizeRamp, colorizeDimension, visible) {
    this._url = urlarg;
    this._quadtree = undefined;
    this._tilingScheme = new Cesium.GeographicTilingScheme();
    this._errorEvent = new Cesium.Event();
    this._levelZeroMaximumError = Cesium.QuadtreeTileProvider.computeDefaultLevelZeroMaximumGeometricError(this._tilingScheme);

    this.header = new PPCCHeader(urlarg, colorizeRamp, colorizeDimension, visible);
};


Object.defineProperties(PPCCProvider.prototype, {
    quadtree : {
        get : function() {
            return this._quadtree;
        },
        set : function(value) {
            this._quadtree = value;
        }
    },
    ready : {
        get : function() {
            return true;
        }
    },
    tilingScheme : {
        get : function() {
            return this._tilingScheme;
        }
    },
    errorEvent : {
        get : function() {
            return this._errorEvent;
        }
    }
});


PPCCProvider.prototype.readHeaderAsync = function() {

    var deferred = Cesium.when.defer();

    var that = this;

    this.header.readHeaderAsync().then(function(hdr) {
        deferred.resolve(hdr);

    }).otherwise(function() {
        myassert(false);
    });

    return deferred.promise;
}

PPCCProvider.prototype.beginUpdate = function(context, frameState, commandList) {
};


PPCCProvider.prototype.endUpdate = function(context, frameState, commandList) {
};


PPCCProvider.prototype.getLevelMaximumGeometricError = function(level) {
    return this._levelZeroMaximumError / (1 << level);
};


PPCCProvider.prototype.loadTile = function(context, frameState, tile) {
    //mylog("?: " + tilename(tile));

    // first, see if we even have the file we need
    if (tile.state === Cesium.QuadtreeTileLoadState.START) {

        // only one of these will be true
        var fileDoesNotExist = false;
        var fileDoesExist = false;
        var fileMightExist = false;

        if (tile.parent == undefined || tile.parent == null) {
            // root tile, file will always be present
            fileDoesExist = true;
        } else {
            //mylog("parent of: " + tilename(tile) + " is " + tilename(tile.parent));
            if (tile.parent.data == undefined || tile.parent.data.ppcc == undefined || !tile.parent.data.ppcc.ready) {
                // parent not available for us to ask it
                //fileMightExist = true;
                fileDoesNotExist = true;
            } else {
                var pX = tile.parent.x;
                var pY = tile.parent.y;
                var hasChild = tile.parent.data.ppcc.isChildAvailable(pX, pY, tile.x, tile.y);
                if (hasChild) {
                    fileDoesExist = true;
                } else {
                    fileDoesNotExist = true;
                }
            }
        }

        myassert((fileDoesExist && !fileDoesNotExist && !fileMightExist) ||
                 (!fileDoesExist && fileDoesNotExist && !fileMightExist) ||
                 (!fileDoesExist && !fileDoesNotExist && fileMightExist));

        if (fileDoesExist) {
            // just drop through to below
            //mylog("OK to start: " + tilename(tile));
        } else if (fileDoesNotExist) {
            tile.renderable = true;
            tile.state = Cesium.QuadtreeTileLoadState.DONE;
        tile.data = {
            primitive : undefined,
            freeResources : function() {
                if (Cesium.defined(this.primitive)) {
                    this.primitive.destroy();
                    this.primitive = undefined;
                }
            }
        };
        tile.data.boundingSphere3D = Cesium.BoundingSphere.fromRectangle3D(tile.rectangle);
        tile.data.boundingSphere2D = Cesium.BoundingSphere.fromRectangle2D(tile.rectangle, frameState.mapProjection);
        Cesium.Cartesian3.fromElements(tile.data.boundingSphere2D.center.z, tile.data.boundingSphere2D.center.x, tile.data.boundingSphere2D.center.y, tile.data.boundingSphere2D.center);
            //mylog("DONE/dne: " + tilename(tile));
            return;
        } else {
            // state unknown right now
            //mylog("UNK: " + tilename(tile));
            return;
        }
    }

    if (tile.state === Cesium.QuadtreeTileLoadState.START) {
        //mylog("START: " + tilename(tile));

        tile.data = {
            primitive : undefined,
            freeResources : function() {
                if (Cesium.defined(this.primitive)) {
                    this.primitive.destroy();
                    this.primitive = undefined;
                }
            }
        };
        /*var color = Cesium.Color.fromBytes(255, 0, 0, 255);
        tile.data.primitive = new Cesium.Primitive({
            geometryInstances : new Cesium.GeometryInstance({
                geometry : new Cesium.RectangleOutlineGeometry({
                    rectangle : tile.rectangle
                }),
                attributes : {
                    color : Cesium.ColorGeometryInstanceAttribute.fromColor(color)
                }
            }),
            appearance : new Cesium.PerInstanceColorAppearance({
                flat : true
            })
        });*/
        tile.data.ppcc = new PPCCTile(this.header, tile.level, tile.x, tile.y);
        tile.data.ppcc.load();

        tile.data.boundingSphere3D = Cesium.BoundingSphere.fromRectangle3D(tile.rectangle);
        tile.data.boundingSphere2D = Cesium.BoundingSphere.fromRectangle2D(tile.rectangle, frameState.mapProjection);
        Cesium.Cartesian3.fromElements(tile.data.boundingSphere2D.center.z, tile.data.boundingSphere2D.center.x, tile.data.boundingSphere2D.center.y, tile.data.boundingSphere2D.center);
        tile.state = Cesium.QuadtreeTileLoadState.LOADING;
        myassert(tile.data.ppcc != null);
        //mylog("LOADING: " + tilename(tile));
    }
    if (tile.state === Cesium.QuadtreeTileLoadState.LOADING && tile.data.ppcc.ready) {

        tile.data.primitive = tile.data.ppcc.primitive;

        if (tile.data.primitive == null) {
            tile.state = Cesium.QuadtreeTileLoadState.DONE;
            tile.renderable = true;
            //mylog("DONE/0: " + tilename(tile));
        } else {
            tile.data.primitive.update(context, frameState, []);
            if (tile.data.primitive.ready) {
                tile.state = Cesium.QuadtreeTileLoadState.DONE;
                tile.renderable = true;
                //mylog("DONE/ok: " + tilename(tile));
            }
        }
    }
};


PPCCProvider.prototype.computeTileVisibility = function(tile, frameState, occluders) {
    var boundingSphere;
    if (frameState.mode === Cesium.SceneMode.SCENE3D) {
        boundingSphere = tile.data.boundingSphere3D;
    } else {
        boundingSphere = tile.data.boundingSphere2D;
    }
    return frameState.cullingVolume.computeVisibility(boundingSphere);
};


PPCCProvider.prototype.showTileThisFrame = function(tile, context, frameState, commandList) {
    //mylog("prim update: " + tilename(tile));
    if (tile.data.primitive != null)
    tile.data.primitive.update(context, frameState, commandList);
};


var subtractScratch = new Cesium.Cartesian3();

PPCCProvider.prototype.computeDistanceToTile = function(tile, frameState) {
    var boundingSphere;
    if (frameState.mode === Cesium.SceneMode.SCENE3D) {
        boundingSphere = tile.data.boundingSphere3D;
    } else {
        boundingSphere = tile.data.boundingSphere2D;
    }
    return Math.max(0.0, Cesium.Cartesian3.magnitude(Cesium.Cartesian3.subtract(boundingSphere.center, frameState.camera.positionWC, subtractScratch)) - boundingSphere.radius);
};


PPCCProvider.prototype.isDestroyed = function() {
    return false;
};


PPCCProvider.prototype.destroy = function() {
    return Cesium.destroyObject(this);
};


//////////////////////////////////////////////////


var PPCCHeader = function PPCCHeader(url, colorizeRamp, colorizeDimension, visible) {
    "use strict";

    this._ready = false;

    this.url = url;
    this.rampName = colorizeRamp;
    this.colorizeDimension = colorizeDimension;
    this.visibility = visible;

    this.info = undefined;

    this.pointSizeInBytes = undefined;
};


Object.defineProperties(PPCCHeader.prototype, {
    ready : {
        get : function () {
            "use strict";
            //mylog("ready check" + this._ready);
            return this._ready;
        }
    }
});


PPCCHeader.prototype.setColorization = function (rampName, dimensionName) {
    "use strict";

    this.rampName = rampName;
    this.colorizeDimension = dimensionName;
};


PPCCHeader.prototype.setVisibility = function (v) {
    "use strict";

    this.visibility = v;
};


PPCCHeader.prototype._computePointSize = function () {
    "use strict";

    var dims = this.info.dimensions;
    var tot = 0;
    var i;

    var sizes = {
        "uint8_t": 1,
        "int8_t": 1,
        "uint16_t": 2,
        "int16_t": 2,
        "uint32_t": 4,
        "int32_t": 4,
        "uint64_t": 8,
        "int64_t": 8,
        "float": 4,
        "double": 8
    };

    for (i = 0; i < dims.length; i += 1) {
        dims[i].offset = tot;
        myassert(sizes[dims[i].datatype] != undefined);
        tot += sizes[dims[i].datatype];
    }

    return tot;
};


// will set this.ready when done
// returns a promise of this header
PPCCHeader.prototype.readHeaderAsync = function () {
    "use strict";

    var deferred = Cesium.when.defer();

    var that = this;

    var url = this.url + "/header.json";

    Cesium.loadJson(url).then(function (json) {
        that.info = json;
        that.pointSizeInBytes = that._computePointSize();

        that._ready = true;
        deferred.resolve(that);

    }).otherwise(function () {
        myerror("Failed to load JSON: " + url);
    });

    return deferred.promise;
};


///////////////////////////////////////////////////////////////////////////////


var PPCCTile = function PPCCTile(header, level, x, y) {
    this._header = header;
    this._x = x;
    this._y = y;
    this._level = level;

    this._primitive = undefined;
    this.url = this._header.url + "/" + level + "/" + x + "/" + y + ".ria";
    this.dimensions = undefined; // list of arrays of dimension data
    this.sw = false;
    this.se = false;
    this.nw = false;
    this.ne = false;
    this._childTileMask = undefined;

    this._ready = false;
}


Object.defineProperties(PPCCTile.prototype, {
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
PPCCTile.prototype.load = function() {
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


PPCCTile.prototype._loadFromBuffer = function (buffer) {
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


PPCCTile.prototype._createDimensionArrays = function (dataview, numBytes) {
    "use strict";

    var headerDims = this._header.info.dimensions;
    var i;
    var datatype,
        offset,
        stride,
        name,
        v;

    var pointSize = this._header.pointSizeInBytes;

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
PPCCTile.prototype._extractDimensionArray = function (dataview, datatype, offset, stride, len) {
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

PPCCTile.prototype._setChildren = function (mask) {
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
PPCCTile.prototype.Cartesian3_fromDegreesArrayHeights_merge = function (x, y, z, cnt, ellipsoid) {
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
PPCCTile.prototype.createPrimitive = function (cnt, dims) {
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


PPCCTile.prototype.colorize = function () {

    var headerDims = this._header.info.dimensions;
    var min, max;
    for (var i=0; i<headerDims.length; i++) {
        if (headerDims[i].name == this._header.colorizeDimension) {
            min = headerDims[i].min;
            max = headerDims[i].max;
            break;
        }
    }

    var nam = this._header.colorizeDimension;
    var dataArray = this.dimensions[nam];
    var rgba = "rgba";
    var rgbaArray = this.dimensions[rgba];

    doColorize(this._header.rampName, dataArray, this.numPoints, min, max, rgbaArray);
};


PPCCTile.prototype.isChildAvailable = function(thisX, thisY, childX, childY) {

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
