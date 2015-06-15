// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


var PointCloudProvider = function PointCloudProvider(urlarg, colorizeRamp, colorizeDimension, visible) {
    this._url = urlarg;
    this._quadtree = undefined;
    this._tilingScheme = new Cesium.GeographicTilingScheme();
    this._errorEvent = new Cesium.Event();
    this._levelZeroMaximumError = Cesium.QuadtreeTileProvider.computeDefaultLevelZeroMaximumGeometricError(this._tilingScheme);

    this._ready = false;

    this.rampName = colorizeRamp;
    this.colorizeDimension = colorizeDimension;
    this.visibility = visible;

    this.header = undefined;
};


Object.defineProperties(PointCloudProvider.prototype, {
    ready : {
        get : function () {
            "use strict";
            //mylog("ready check" + this._ready);
            return this._ready;
        }
    },
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


// will set this.ready when done
// returns a promise of this header
PointCloudProvider.prototype.readHeaderAsync = function () {
    "use strict";

    var deferred = Cesium.when.defer();

    var that = this;
    var url = this._url;

    Cesium.loadJson(url).then(function (json) {
        that.header = json;
        that.header.pointSizeInBytes = that._computePointSize();

        that._ready = true;
        deferred.resolve(that);
    }).otherwise(function () {
        myerror("Failed to load JSON: " + url);
    });

    return deferred.promise;
};


PointCloudProvider.prototype.setColorization = function (rampName, dimensionName) {
    "use strict";

    this.rampName = rampName;
    this.colorizeDimension = dimensionName;
};


PointCloudProvider.prototype.setVisibility = function (v) {
    "use strict";

    this.visibility = v;
};


PointCloudProvider.prototype._computePointSize = function () {
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

    //mylog("Point size: " + tot);

    return tot;
};


//////////////////////////

PointCloudProvider.prototype.beginUpdate = function(context, frameState, commandList) {
};


PointCloudProvider.prototype.endUpdate = function(context, frameState, commandList) {
};


PointCloudProvider.prototype.getLevelMaximumGeometricError = function(level) {
    return this._levelZeroMaximumError / (1 << level);
};


// The underlying tile system is such that we will never be asked
// for a tile unless we have resolved it's parent first.
//
// returns:
//   true - the tile does exist in the DB
//   false - we are certain that the tile does not exist in the DB
PointCloudProvider.prototype.checkExistence = function(tile)
{
    if (tile.parent == undefined || tile.parent == null) {
        // This is a root tile. The server will always tell us that the root
        // tiles exist in the database. (It may not actually be in the database,
        // but for now the server is designed to return an empty tile if the
        // tile isn't present -- since Cesium will only ask for tiles it knows
        // exist, the server will only ever "lie" about root tiles.)
        return true;
    }

    myassert(tile.parent.state == Cesium.QuadtreeTileLoadState.DONE);

    //mylog("parent of: " + tile.name + " is " + tile.parent.name);
    if (tile.parent.data == undefined || tile.parent.data.ppcc == undefined || !tile.parent.data.ppcc.ready) {
        // parent not available for us to ask it about its child,
        // and if the parent doesn't exist yet then the child must not either
        return false;
    }

    var pX = tile.parent.x;
    var pY = tile.parent.y;
    var hasChild = tile.parent.data.ppcc.isChildAvailable(pX, pY, tile.x, tile.y);
    if (hasChild) {
        return true;
    }
    return false;
}


PointCloudProvider.prototype.initTileData = function(tile, frameState) {

    tile.data = {
        primitive : undefined,
        freeResources : function() {
            if (Cesium.defined(this.primitive) && this.primitive != null) {
                this.primitive.destroy();
                this.primitive = undefined;
                mylog("free: " + tile.level + " " + tile.x + " " + tile.y);

                if (tile.data != undefined && tile.data != null &&
                    tile.data.ppcc != undefined && tile.data.ppcc != null &&
                    tile.data.ppcc.dimensions != undefined && tile.data.ppcc.dimensions != null) {
                    var header = tile.data.ppcc.header;
                    if (header != undefined && header != null) {
                        var headerDims = header.dimensions;
                        for (var i = 0; i < headerDims.length; i += 1) {
                            var name = headerDims[i].name;
                            tile.data.ppcc.dimensions[name] = null;
                        }
                        tile.data.ppcc.dimensions = null;
                    }
                }
            }
        }
    };

    tile.data.boundingSphere3D = Cesium.BoundingSphere.fromRectangle3D(tile.rectangle);
    tile.data.boundingSphere2D = Cesium.BoundingSphere.fromRectangle2D(tile.rectangle, frameState.mapProjection);
    Cesium.Cartesian3.fromElements(tile.data.boundingSphere2D.center.z, tile.data.boundingSphere2D.center.x, tile.data.boundingSphere2D.center.y, tile.data.boundingSphere2D.center);
}


PointCloudProvider.prototype.loadTile = function(context, frameState, tile) {
    //mylog("?: " + tile.level + " " + tile.x + " " + tile.y);

    myassert(tile.state === Cesium.QuadtreeTileLoadState.START ||
             tile.state === Cesium.QuadtreeTileLoadState.LOADING);

    if (tile.state === Cesium.QuadtreeTileLoadState.START) {
        // first, check and see if the tile even exists in the DB
        var exists = this.checkExistence(tile);

        if (exists == false) {
            this.initTileData(tile, frameState);
            tile.renderable = true;
            tile.state = Cesium.QuadtreeTileLoadState.DONE;
            return;
        }

        this.initTileData(tile, frameState);

        tile.data.ppcc = new PointCloudTile(this, tile.level, tile.x, tile.y);
        tile.data.ppcc.load();

        tile.state = Cesium.QuadtreeTileLoadState.LOADING;
    }

    if (tile.state === Cesium.QuadtreeTileLoadState.LOADING && tile.data.ppcc.ready) {

        tile.data.primitive = tile.data.ppcc.primitive;

        if (tile.data.primitive == null) {
            tile.state = Cesium.QuadtreeTileLoadState.DONE;
            tile.renderable = true;
            return;
        }

        tile.data.primitive.update(context, frameState, []);
        if (tile.data.primitive.ready) {
            tile.state = Cesium.QuadtreeTileLoadState.DONE;
            tile.renderable = true;
            return;
        }
    }

    // fall-through case: will need to wait for next time around
};


PointCloudProvider.prototype.computeTileVisibility = function(tile, frameState, occluders) {
    var boundingSphere;
    if (frameState.mode === Cesium.SceneMode.SCENE3D) {
        boundingSphere = tile.data.boundingSphere3D;
    } else {
        boundingSphere = tile.data.boundingSphere2D;
    }
    return frameState.cullingVolume.computeVisibility(boundingSphere);
};


PointCloudProvider.prototype.showTileThisFrame = function(tile, context, frameState, commandList) {
    //mylog("prim update: " + tile.name);
    if (tile.data.primitive != null) {
        tile.data.primitive.update(context, frameState, commandList);
    }
};


var subtractScratch = new Cesium.Cartesian3();

PointCloudProvider.prototype.computeDistanceToTile = function(tile, frameState) {
    var boundingSphere;
    if (frameState.mode === Cesium.SceneMode.SCENE3D) {
        boundingSphere = tile.data.boundingSphere3D;
    } else {
        boundingSphere = tile.data.boundingSphere2D;
    }
    return Math.max(0.0, Cesium.Cartesian3.magnitude(Cesium.Cartesian3.subtract(boundingSphere.center, frameState.camera.positionWC, subtractScratch)) - boundingSphere.radius);
};


PointCloudProvider.prototype.isDestroyed = function() {
    return false;
};


PointCloudProvider.prototype.destroy = function() {
    return Cesium.destroyObject(this);
};
