// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


// based on DemoTileProvider from
// https://github.com/AnalyticalGraphicsInc/cesium/blob/master/Specs/Sandcastle/QuadtreePrimitive.html


var assert = function (b, s) {
    "use strict";

    if (!b) {
        console.log("***** ERROR: " + s);
    }
};


var PCTileProvider = function PCTileProvider(url) {
    "use strict";

    this._quadtree = undefined;
    this._tilingScheme = new Cesium.GeographicTilingScheme();
    this._errorEvent = new Cesium.Event();
    this._levelZeroMaximumError = Cesium.QuadtreeTileProvider.computeDefaultLevelZeroMaximumGeometricError(this._tilingScheme);

    this.url = url;
    this.header = undefined;
    this._ready = false;
    this.pointSizeInBytes = undefined;

    this._tiletree = null;
    this._root000 = null;
    this._root010 = null;

    this.readHeader();
};


Object.defineProperties(PCTileProvider.prototype, {
    quadtree : {
        get : function () {
            "use strict";
            return this._quadtree;
        },
        set : function (value) {
            "use strict";
            this._quadtree = value;
        }
    },
    ready : {
        get : function () {
            "use strict";
            console.log("ready check" + this._ready);
            return this._ready;
        }
    },
    tilingScheme : {
        get : function () {
            "use strict";
            return this._tilingScheme;
        }
    },
    errorEvent : {
        get : function () {
            "use strict";
            return this._errorEvent;
        }
    }
});


PCTileProvider.prototype._computePointSize = function () {
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
        assert(sizes[dims[i].datatype] != undefined);
        tot += sizes[dims[i].datatype];
    }

    return tot;
};


PCTileProvider.prototype.readHeader = function () {
    "use strict";

    var provider = this;

    var url = this.url + "/header.json";

    Cesium.loadJson(url).then(function (json) {
        provider.header = json;
        provider._ready = true;
        provider.pointSizeInBytes = provider._computePointSize();
        console.log("point size: " + provider.pointSizeInBytes);

        provider._tiletree = new PCTileTree(provider);

        provider._root000 = provider._tiletree.createPCTile(0, 0, 0);
        provider._root010 = provider._tiletree.createPCTile(0, 1, 0);
console.log("header read");
    }).otherwise(function () {
        console.log("FAIL getting json: " + url);
    });
};


PCTileProvider.prototype.beginUpdate = function (context, frameState, commandList) {
    "use strict";
};


PCTileProvider.prototype.endUpdate = function (context, frameState, commandList) {
    "use strict";
};


PCTileProvider.prototype.getLevelMaximumGeometricError = function (level) {
    "use strict";

    return this._levelZeroMaximumError / (1 << level);
};



PCTileProvider.prototype._makeRect = function (rect) {
    "use strict";

    var color = Cesium.Color.fromBytes(0, 0, 255, 255);
    var p = new Cesium.Primitive({
        geometryInstances : new Cesium.GeometryInstance({
            geometry : new Cesium.RectangleOutlineGeometry({
                rectangle : rect
            }),
            attributes : {
                color : Cesium.ColorGeometryInstanceAttribute.fromColor(color)
            }
        }),
        appearance : new Cesium.PerInstanceColorAppearance({
            flat : true
        })
    });

    return p;
};


PCTileProvider.prototype.loadTile = function (context, frameState, tile) {
    "use strict";

  //  console.log("PRESTART: " + tile.level + " " + tile.x + " " + tile.y);

    if (tile.state === Cesium.QuadtreeTileLoadState.START) {

        tile.data = {
            primitive : undefined,
            freeResources : function () {
                if (Cesium.defined(this.data) && (this.data != null) &&
                    Cesium.defined(this.data.primitive) && (this.data.primitive != null)) {
                    this.data.primitive.destroy();
                    this.data.primitive = undefined;
                }
            }
        };

        tile.data.primitive = null;

        tile.data.boundingSphere3D = Cesium.BoundingSphere.fromRectangle3D(tile.rectangle);
        tile.data.boundingSphere2D = Cesium.BoundingSphere.fromRectangle2D(tile.rectangle, frameState.mapProjection);
        Cesium.Cartesian3.fromElements(tile.data.boundingSphere2D.center.z, tile.data.boundingSphere2D.center.x, tile.data.boundingSphere2D.center.y, tile.data.boundingSphere2D.center);

        var west = Cesium.Math.toDegrees(tile.rectangle.west);
        var rootTile = (west < 0) ? this._root000 : this._root010;
        var pcTileState = this._tiletree.getTileState(rootTile, tile.level, tile.x, tile.y);

        // console.log("state " + pcTileState + " for " + tile.level + tile.x + tile.y);

        if (pcTileState == csUNKNOWN) {
            // nothing we can do, just wait
            return;
        }

        if (pcTileState == csDOESNOTEXIST) {
            // no data, do nothing
            tile.data.primitive = this._makeRect(tile.rectangle);
            tile.state = Cesium.QuadtreeTileLoadState.DONE;
            tile.renderable = true;
            return;
        }

        assert(pcTileState == csEXISTS, 12);

        var pcTile = this._tiletree.lookupPCTile(tile);
        if (pcTile == null) {
            // not created yet, so start making it
            tile.state = Cesium.QuadtreeTileLoadState.LOADING;
            pcTile = this._tiletree.PCTile(tile.level, tile.x, tile.y);
            pcTile.loadTileData();
            return;
        }

        if (pcTile.state == tsLOADING) {
            // tile exists, but not ready yet, so just wait
            tile.state = Cesium.QuadtreeTileLoadState.LOADING;
            return;
        }

        if (pcTile.state == tsNOTLOADED) {
            // tile not even started yet, so just wait
            tile.state = Cesium.QuadtreeTileLoadState.LOADING;
            pcTile.loadTileData();
            return;
        }

        // the tiule exists and is fully ready: drop through to below if-stmt
        assert(pcTile.state == tsLOADED, 13);

        tile.state = Cesium.QuadtreeTileLoadState.LOADING;
    }

    if (tile.state === Cesium.QuadtreeTileLoadState.LOADING) {
        // console.log("LOADINGx: " + tile.level + " " + tile.x + " " + tile.y);

        var pcTile = this._tiletree.lookupPCTile(tile);
        assert(pcTile != null, 55);

        if (pcTile.state != tsLOADED) {
            // not loaded yet, so wait
            return;
        }

        assert(pcTile.state == tsLOADED, 74);

        tile.data.primitive = pcTile.primitive;

        if (tile.data.primitive == null) {
            // tile is full loaded -- but is an empty tile (no data in it)
            tile.state = Cesium.QuadtreeTileLoadState.DONE;
            tile.renderable = false;
            return;
        }

        assert(tile.data.primitive != null, 72);

        //console.log("LOADINGy: " + tile.level + " " + tile.x + " " + tile.y + "(" + tile.data.primitive._state + ")");
        tile.state = Cesium.QuadtreeTileLoadState.DONE;
        tile.renderable = true;
    }
};


PCTileProvider.prototype.computeTileVisibility = function (tile, frameState, occluders) {
    "use strict";

    var boundingSphere;
    if (frameState.mode === Cesium.SceneMode.SCENE3D) {
        boundingSphere = tile.data.boundingSphere3D;
    } else {
        boundingSphere = tile.data.boundingSphere2D;
    }
    return frameState.cullingVolume.computeVisibility(boundingSphere);
};


PCTileProvider.prototype.showTileThisFrame = function (tile, context, frameState, commandList) {
    "use strict";

    tile.data.primitive.update(context, frameState, commandList);
};


var subtractScratch = new Cesium.Cartesian3();


PCTileProvider.prototype.computeDistanceToTile = function (tile, frameState) {
    "use strict";

    var boundingSphere;
    if (frameState.mode === Cesium.SceneMode.SCENE3D) {
        boundingSphere = tile.data.boundingSphere3D;
    } else {
        boundingSphere = tile.data.boundingSphere2D;
    }
    return Math.max(0.0, Cesium.Cartesian3.magnitude(Cesium.Cartesian3.subtract(boundingSphere.center, frameState.camera.positionWC, subtractScratch)) - boundingSphere.radius);
};


PCTileProvider.prototype.isDestroyed = function () {
    "use strict";

    return false;
};


PCTileProvider.prototype.destroy = function () {
    "use strict";

    return Cesium.destroyObject(this);
};
