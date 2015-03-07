
//
// options:
//   url
//   proxy
//
var PointCloudTileProvider = function PointCloudTileProvider(options) {
    "use strict";

    if (!Cesium.defined(options) || !Cesium.defined(options.url)) {
        throw new Cesium.DeveloperError('options.url is required.');
    }

    this._url = Cesium.appendForwardSlash(options.url);
    this._proxy = options.proxy;

    this._tilingScheme = new Cesium.GeographicTilingScheme({
        numberOfLevelZeroTilesX : 2,
        numberOfLevelZeroTilesY : 1
    });

    this._quadtree = undefined;
    this._errorEvent = new Cesium.Event();
    this._levelZeroMaximumError = Cesium.QuadtreeTileProvider.computeDefaultLevelZeroMaximumGeometricError(this._tilingScheme);

    this._tileUrlTemplate = this._url + "{level}/{x}/{y}.ria";

    this._ready = false;
};


Object.defineProperties(PointCloudTileProvider.prototype, {

    quadtree : {
        get : function() {
            return this._quadtree;
        },
        set : function(value) {
            this._quadtree = value;
        }
    },

    errorEvent : {
        get : function() {
            return this._errorEvent;
        }
    },

    tilingScheme : {
        get : function() {
            if (!this._ready) {
                throw new Cesium.DeveloperError('tilingScheme must not be called before the point cloud tile provider is ready.');
            }

            return this._tilingScheme;
        }
    },

    ready : {
        get : function() {
            return this._ready;
        }
    }
});


// returns a promise<provider>
PointCloudTileProvider.prototype.readHeaderAsync = function () {
    "use strict";

    var provider = this;

    var metadataUrl = this._url + 'header.json';
    if (Cesium.defined(this._proxy)) {
        metadataUrl = this._proxy.getURL(metadataUrl);
    }

    var deferred = Cesium.when.defer();

    var that = this;

    Cesium.loadJson(metadataUrl).then(function (data) {

        var baseUri = new Cesium.Uri(metadataUrl);

        //that._tileUrlTemplates = data.tiles;
        //for (i = 0; i < that._tileUrlTemplates.length; i += 1) {
        //    that._tileUrlTemplates[i] = new Uri(that._tileUrlTemplates[i]).resolve(baseUri).toString().replace('{version}', data.version);
        //}

        /* that._availableTiles = data.available; */

        provider.header = data;

        provider.header.pointSizeInBytes = that._computePointSize();

        that._ready = true;
        deferred.resolve(provider);

    }).otherwise(function () {
        myerror("Failed to load JSON: " + metadataUrl);
    });

    return deferred.promise;
};


PointCloudTileProvider.prototype._computePointSize = function () {
    "use strict";

    var dims = this.header.dimensions;
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


PointCloudTileProvider.prototype.beginUpdate = function(context, frameState, commandList) {
};


PointCloudTileProvider.prototype.endUpdate = function(context, frameState, commandList) {
};






PointCloudTileProvider.prototype.getLevelMaximumGeometricError = function(level) {
    "use strict";

    return this._levelZeroMaximumGeometricError / (1 << level);
};


// taken from Cartesian3.fromDegreesArrayHeights
PointCloudTileProvider.prototype.Cartesian3_fromDegreesArrayHeights_merge = function (x, y, z, cnt, ellipsoid) {
    "use strict";

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
PointCloudTileProvider.prototype.createPrimitive = function (cnt, dims) {

    if (cnt == 0) {
        return null;
    }

    var x = dims["X"];
    var y = dims["Y"];
    var z = dims["Z"];
    var rgba = dims["rgba"];

    var xyz = this.Cartesian3_fromDegreesArrayHeights_merge(x, y, z, cnt);

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

    mylog("made prim!");
    return prim;
};



PointCloudTileProvider.prototype.loadTile = function(context, frameState, tile) {
var that=this;
    if (tile.state === Cesium.QuadtreeTileLoadState.START) {

        mylog("asking for " + tile.level + " " + tile.x + " " + tile.y);

        if (tile.parent != undefined && tile.parent != null) {
            mylog("  has parent");
            if (tile.parent.data == undefined || tile.parent.data == null) {
                mylog("*****************ERROR**************");
            }
            var mask = tile.parent.data.childMask;
            var px = tile.parent.x;
            var py = tile.parent.y;
            var cx = tile.x;
            var cy = tile.y;
            var thisChildIsAvailable = this.isChildAvailable(mask, px, py, cx, cy);
            if (thisChildIsAvailable) {
                mylog(" is available");
            } else {
                mylog(" IS NOT AVAILABLE");
            }
        }

        tile.data = {
            primitive : undefined,
            freeResources : function() {
                if (Cesium.defined(this.primitive)) {
                    this.primitive.destroy();
                    this.primitive = undefined;
                }
            }
        };

        function success(data) {

            this.data = data;

            tile.data.primitive = that.createPrimitive(data.numPoints, data.dimensions);

            tile.data.boundingSphere3D = Cesium.BoundingSphere.fromRectangle3D(tile.rectangle);
            tile.data.boundingSphere2D = Cesium.BoundingSphere.fromRectangle2D(tile.rectangle, frameState.mapProjection);
            Cesium.Cartesian3.fromElements(tile.data.boundingSphere2D.center.z, tile.data.boundingSphere2D.center.x, tile.data.boundingSphere2D.center.y, tile.data.boundingSphere2D.center);


            tile.state = Cesium.QuadtreeTileLoadState.LOADING;
        };


        function failure(e) {
            myassert(false, 100);
        };

        // returns a promise of a PointCloudData
        var thing = this.requestTileGeometry(tile.x, tile.y, tile.level);
        Cesium.when(thing, success, failure);
    }

    if (tile.state === Cesium.QuadtreeTileLoadState.LOADING) {

        if (tile.data.primitive == null) {
                tile.state = Cesium.QuadtreeTileLoadState.DONE;
                tile.renderable = true;
        } else {
            tile.data.primitive.update(context, frameState, []);
            if (tile.data.primitive.ready) {
                tile.state = Cesium.QuadtreeTileLoadState.DONE;
                tile.renderable = true;
            }
        }
    }
};


 PointCloudTileProvider.prototype.isChildAvailable = function(mask, thisX, thisY, childX, childY) {
                if (!Cesium.defined(thisX)) {
            throw new Cesium.DeveloperError('thisX is required.');
        }
        if (!Cesium.defined(thisY)) {
            throw new Cesium.DeveloperError('thisY is required.');
        }
        if (!Cesium.defined(childX)) {
            throw new Cesium.DeveloperError('childX is required.');
        }
        if (!Cesium.defined(childY)) {
            throw new Cesium.DeveloperError('childY is required.');
        }

        var bitNumber = 2; // northwest child
        if (childX !== thisX * 2) {
            ++bitNumber; // east child
        }
        if (childY !== thisY * 2) {
            bitNumber -= 2; // south child
        }

        return (mask & (1 << bitNumber)) !== 0;
    };



PointCloudTileProvider.prototype.computeTileVisibility = function(tile, frameState, occluders) {
    var boundingSphere;
    if (frameState.mode === Cesium.SceneMode.SCENE3D) {
        boundingSphere = tile.data.boundingSphere3D;
    } else {
        boundingSphere = tile.data.boundingSphere2D;
    }

    return frameState.cullingVolume.computeVisibility(boundingSphere);
};

PointCloudTileProvider.prototype.showTileThisFrame = function(tile, context, frameState, commandList) {
    if (tile.data.primitive != null) {
        tile.data.primitive.update(context, frameState, commandList);
    }
};

var subtractScratch = new Cesium.Cartesian3();

PointCloudTileProvider.prototype.computeDistanceToTile = function(tile, frameState) {
    var boundingSphere;

    if (frameState.mode === Cesium.SceneMode.SCENE3D) {
        boundingSphere = tile.data.boundingSphere3D;
    } else {
        boundingSphere = tile.data.boundingSphere2D;
    }

    return Math.max(0.0, Cesium.Cartesian3.magnitude(Cesium.Cartesian3.subtract(boundingSphere.center, frameState.camera.positionWC, subtractScratch)) - boundingSphere.radius);
};

PointCloudTileProvider.prototype.isDestroyed = function() {
    return false;
};

PointCloudTileProvider.prototype.destroy = function() {
    return Cesium.destroyObject(this);
};


PointCloudTileProvider.prototype._getRequestHeader = function() {
    "use strict";
        return {
            Accept : 'application/octet-stream;q=0.9,*/*;q=0.01'
        };
};


PointCloudTileProvider.prototype._createPointCloudTileData = function(buffer, level, x, y) {
    "use strict";

     var dataview = new DataView(buffer, 0, buffer.byteLength - 1);
     var childMask = new Uint8Array(buffer, buffer.byteLength-1, 1)[0];

     return new PointCloudTileData(dataview, childMask, this.header);
};


PointCloudTileProvider.prototype.requestTileGeometry = function(x, y, level, throttleRequests) {
    "use strict";

    if (!this._ready) {
        throw new Cesium.DeveloperError('requestTileGeometry must not be called before the tile provider is ready.');
    }

    var url = this._tileUrlTemplate.replace('{level}', level).replace('{x}', x).replace('{y}', y);

    var proxy = this._proxy;
    if (Cesium.defined(proxy)) {
        url = proxy.getURL(url);
    }

    var promise;

    var that = this;

    var tileLoader = function(tileUrl) {
        return Cesium.loadArrayBuffer(tileUrl, that._getRequestHeader());
    };

    throttleRequests = Cesium.defaultValue(throttleRequests, true);
    if (throttleRequests) {
        promise = Cesium.throttleRequestByServer(url, tileLoader);
        if (!Cesium.defined(promise)) {
            return undefined;
        }
    } else {
        promise = tileLoader(url);
    }

    return Cesium.when(promise, function(buffer) {

        var r= that._createPointCloudTileData(buffer, level, x, y);
         return r;
    });
};


PointCloudTileProvider.prototype._getChildMaskForTile = function (terrainProvider, level, x, y) {
    "use strict";

    var available = terrainProvider._availableTiles;
    if (!available || available.length === 0) {
        return 15;
    }

    var childLevel = level + 1;
    if (childLevel >= available.length) {
        return 0;
    }

    var levelAvailable = available[childLevel];

    var mask = 0;

    mask |= isTileInRange(levelAvailable, 2 * x, 2 * y) ? 1 : 0;
    mask |= isTileInRange(levelAvailable, 2 * x + 1, 2 * y) ? 2 : 0;
    mask |= isTileInRange(levelAvailable, 2 * x, 2 * y + 1) ? 4 : 0;
    mask |= isTileInRange(levelAvailable, 2 * x + 1, 2 * y + 1) ? 8 : 0;

    return mask;
};


PointCloudTileProvider.prototype._isTileInRange = function(levelAvailable, x, y) {
    "use strict";

    var i;
    var range;
    var len;

    for (i = 0, len = levelAvailable.length; i < len; i += 1) {
        range = levelAvailable[i];
        if (x >= range.startX && x <= range.endX && y >= range.startY && y <= range.endY) {
            return true;
        }
    }

    return false;
};


PointCloudTileProvider.prototype.getTileDataAvailable = function(x, y, level) {
    "use strict";

    var available = this._availableTiles;

    if (!available || available.length === 0) {
        return undefined;
    }

    if (level >= available.length) {
        return false;
    }

    var levelAvailable = available[level];
    var yTiles = this._tilingScheme.getNumberOfYTilesAtLevel(level);
    var tmsY = (yTiles - y - 1);
    return isTileInRange(levelAvailable, x, tmsY);
};
