
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

        that._ready = true;
        deferred.resolve(provider);

    }).otherwise(function () {
        myerror("Failed to load JSON: " + metadataUrl);
    });

    return deferred.promise;
};


PointCloudTileProvider.prototype.beginUpdate = function(context, frameState, commandList) {
}


PointCloudTileProvider.prototype.endUpdate = function(context, frameState, commandList) {
}






PointCloudTileProvider.prototype.getLevelMaximumGeometricError = function(level) {
    "use strict";

    return this._levelZeroMaximumGeometricError / (1 << level);
};


PointCloudTileProvider.prototype.loadTile = function(context, frameState, tile) {

    if (tile.state === Cesium.QuadtreeTileLoadState.START) {
        mylog("asking for " + tile.x + " " + tile.y + " " + tile.level);

        // returns a promise of a PointCloudData
        this.requestTileGeometry(tile.x, tile.y, tile.level);

        tile.data = {
            primitive : undefined,
            freeResources : function() {
                if (Cesium.defined(this.primitive)) {
                    this.primitive.destroy();
                    this.primitive = undefined;
                }
            }
        };
        var color = Cesium.Color.fromBytes(255, 0, 0, 255);

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
        });

        tile.data.boundingSphere3D = Cesium.BoundingSphere.fromRectangle3D(tile.rectangle);
        tile.data.boundingSphere2D = Cesium.BoundingSphere.fromRectangle2D(tile.rectangle, frameState.mapProjection);
        Cesium.Cartesian3.fromElements(tile.data.boundingSphere2D.center.z, tile.data.boundingSphere2D.center.x, tile.data.boundingSphere2D.center.y, tile.data.boundingSphere2D.center);

        tile.state = Cesium.QuadtreeTileLoadState.LOADING;
    }

    if (tile.state === Cesium.QuadtreeTileLoadState.LOADING) {
        tile.data.primitive.update(context, frameState, []);
        if (tile.data.primitive.ready) {
            tile.state = Cesium.QuadtreeTileLoadState.DONE;
            tile.renderable = true;
        }
    }
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
    tile.data.primitive.update(context, frameState, commandList);
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

    mylog("IIIIIIIIIIIIIIIIIIIIIIIIIIIIII: " + buffer);

    var heightBuffer = new Uint16Array(buffer, 0, provider._heightmapWidth * provider._heightmapWidth);

    return new PointCloudTileData({
        buffer : heightBuffer,
        childTileMask : new Uint8Array(buffer, heightBuffer.byteLength, 1)[0],
        width : provider._heightmapWidth,
        height : provider._heightmapWidth,
        structure : provider._heightmapStructure
    });
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
        return that._createPointCloudTileData(buffer, level, x, y);
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
