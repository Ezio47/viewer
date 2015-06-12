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


// returns:
//   true - file does exist
//   false - file does not exist
//   null - file might or might not exist
PointCloudProvider.prototype.checkExistence = function(tile) {

    // only one of these will be true
    var fileDoesNotExist = false;
    var fileDoesExist = false;
    var fileMightExist = false;

    if (tile.parent == undefined || tile.parent == null) {
        // root tile, file will always be present
        fileDoesExist = true;
    } else {
        //mylog("parent of: " + tile.name + " is " + tile.parent.name);
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

    if (fileDoesExist) return true;
    if (fileDoesNotExist) return false;
    return null;
}


PointCloudProvider.prototype.initTileData = function(tile, frameState) {

    tile.data = {
        primitive : undefined,
        freeResources : function() {
            if (Cesium.defined(this.primitive) && this.primitive != null) {
                this.primitive.destroy();
                this.primitive = undefined;
            }
        }
    };

    tile.data.boundingSphere3D = Cesium.BoundingSphere.fromRectangle3D(tile.rectangle);
    tile.data.boundingSphere2D = Cesium.BoundingSphere.fromRectangle2D(tile.rectangle, frameState.mapProjection);
    Cesium.Cartesian3.fromElements(tile.data.boundingSphere2D.center.z, tile.data.boundingSphere2D.center.x, tile.data.boundingSphere2D.center.y, tile.data.boundingSphere2D.center);
}


PointCloudProvider.prototype.loadTile = function(context, frameState, tile) {
    //mylog("?: " + tile.level + " " + tile.x + " " + tile.y);

    // first, see if we even have the file we need
    if (tile.state === Cesium.QuadtreeTileLoadState.START) {
        var exists = this.checkExistence(tile);

        if (exists == null) {
            // state unknown right now
            //mylog("UNK: " + tile.name);
            return;
        }

        if (exists == false) {
            this.initTileData(tile, frameState);
            tile.renderable = true;
            tile.state = Cesium.QuadtreeTileLoadState.DONE;

            //mylog("DONE/dne: " + tile.name);
            return;
        }

        myassert(exists == true);
        // just drop through to below

        //mylog("OK to start: " + tile.name);
    }

    if (tile.state === Cesium.QuadtreeTileLoadState.START) {
        //mylog("START: " + tile.name);

        this.initTileData(tile, frameState);

        tile.data.ppcc = new PointCloudTile(this, tile.level, tile.x, tile.y);
        tile.data.ppcc.load();

        tile.state = Cesium.QuadtreeTileLoadState.LOADING;
        myassert(tile.data.ppcc != null);
        //mylog("LOADING: " + tile.name);
    }

    if (tile.state === Cesium.QuadtreeTileLoadState.LOADING && tile.data.ppcc.ready) {

        tile.data.primitive = tile.data.ppcc.primitive;

        if (tile.data.primitive == null) {
            tile.state = Cesium.QuadtreeTileLoadState.DONE;
            tile.renderable = true;
            //mylog("DONE/0: " + tile.name);
        } else {
            tile.data.primitive.update(context, frameState, []);
            if (tile.data.primitive.ready) {
                tile.state = Cesium.QuadtreeTileLoadState.DONE;
                tile.renderable = true;
                //mylog("DONE/ok: " + tile.level + " " + tile.x + " " + tile.y);
            }
        }
    }
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
