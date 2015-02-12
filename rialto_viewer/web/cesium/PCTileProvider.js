// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


// based on DemoTileProvider from
// https://github.com/AnalyticalGraphicsInc/cesium/blob/master/Specs/Sandcastle/QuadtreePrimitive.html

"use strict";


var assert = function(b, s) {
    if (!b) console.log("***** ERROR: " + s);
}

var PCTileProvider = function PCTileProvider(urlPath, creatorCallback, getterCallback) {
    this._quadtree = undefined;
    this._tilingScheme = new Cesium.GeographicTilingScheme();
    this._errorEvent = new Cesium.Event();
    this._tileCreatorCallback = creatorCallback;
    this._tileGetterCallback = getterCallback;
    this._levelZeroMaximumError = Cesium.QuadtreeTileProvider.computeDefaultLevelZeroMaximumGeometricError(this._tilingScheme);

    this._tiletree = new PCTileTree(urlPath);

    this._root000 = this._tiletree.createTile(0, 0, 0);

    this._root010 = this._tiletree.createTile(0, 1, 0);
};


Object.defineProperties(PCTileProvider.prototype, {
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


PCTileProvider.prototype.beginUpdate = function(context, frameState, commandList) {
};


PCTileProvider.prototype.endUpdate = function(context, frameState, commandList) {
};


PCTileProvider.prototype.getLevelMaximumGeometricError = function(level) {
    return this._levelZeroMaximumError / (1 << level);
};



PCTileProvider.prototype._makeRect = function(rect) {
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


PCTileProvider.prototype.loadTile = function(context, frameState, tile) {

    //console.log("PRESTART: " + tile.level + " " + tile.x + " " + tile.y);

    if (tile.state === Cesium.QuadtreeTileLoadState.START) {

        var west = Cesium.Math.toDegrees(tile.rectangle.west);
        var south = Cesium.Math.toDegrees(tile.rectangle.south);
        var east = Cesium.Math.toDegrees(tile.rectangle.east);
        var north = Cesium.Math.toDegrees(tile.rectangle.north);

        tile.data = {
            primitive : undefined,
            freeResources : function() {
                return;
                if (Cesium.defined(this.primitive)) {
                    this.primitive.destroy();
                    this.primitive = undefined;
                }
            }
        };

        tile.data.primitive = null;

        tile.data.boundingSphere3D = Cesium.BoundingSphere.fromRectangle3D(tile.rectangle);
        tile.data.boundingSphere2D = Cesium.BoundingSphere.fromRectangle2D(tile.rectangle, frameState.mapProjection);
        Cesium.Cartesian3.fromElements(tile.data.boundingSphere2D.center.z, tile.data.boundingSphere2D.center.x, tile.data.boundingSphere2D.center.y, tile.data.boundingSphere2D.center);

        var tileCreatorCallback = this._tileCreatorCallback;

        var root = (west < 0) ? this._root000 : this._root010;
        var pcTileState = this._tiletree.getTileState(root, tile.level, tile.x, tile.y);

        //console.log("state " + pcTileState + " for " + tile.level + tile.x + tile.y);

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

        var pcTile = this._tiletree.lookupTile(tile.level, tile.x, tile.y);
        if (pcTile == null) {
            //console.log("and creating");
            pcTile = this._tiletree.createTile(tile.level, tile.x, tile.y);
            pcTile.loadTileData();
            return;
        }

        // the tile exists...
        if (pcTile.state == tsLOADING) {
            //console.log("and waiting on loading");
            // just wait
            return;
        }

        // the tile exists...
        if (pcTile.state == tsNOTLOADED) {
            //console.log("and waiting on notloaded");
            pcTile.loadTileData();
            return;
        }

        assert(pcTile.state == tsLOADED, 13);
        //console.log("and continuing");

        this._tileCreatorCallback(tile.level, tile.x, tile.y, west, south, east, north, pcTile.buffer);
        tile.state = Cesium.QuadtreeTileLoadState.LOADING;
    }

    if (tile.state === Cesium.QuadtreeTileLoadState.LOADING) {
        //console.log("LOADINGx: " + tile.level + " " + tile.x + " " + tile.y);// + "(" + tile.data.primitive.ready + ")");

        var pcTile = this._tiletree.lookupTile(tile.level, tile.x, tile.y);
        assert(pcTile != null);

        assert(pcTile.state == tsLOADED);

        if (tile.data.primitive == null) {
            tile.data.primitive = this._tileGetterCallback(tile.level, tile.x, tile.y);
            if (tile.data.primitive == null) {
                // tile w/ no data in it
                tile.state = Cesium.QuadtreeTileLoadState.DONE;
                tile.renderable = false;
                return;
            }
        }

        if (tile.data.primitive != null) {
            tile.data.primitive.update(context, frameState, []);
            //console.log("LOADINGy: " + tile.level + " " + tile.x + " " + tile.y + "(" + tile.data.primitive.ready + ")");
            if (tile.data.primitive.ready) {
                //console.log("LOADINGz: " + tile.level + " " + tile.x + " " + tile.y);
                tile.state = Cesium.QuadtreeTileLoadState.DONE;
                tile.renderable = true;
            }
        }
    }
};


PCTileProvider.prototype.computeTileVisibility = function(tile, frameState, occluders) {
    var boundingSphere;
    if (frameState.mode === Cesium.SceneMode.SCENE3D) {
        boundingSphere = tile.data.boundingSphere3D;
    } else {
        boundingSphere = tile.data.boundingSphere2D;
    }
    return frameState.cullingVolume.computeVisibility(boundingSphere);
};


PCTileProvider.prototype.showTileThisFrame = function(tile, context, frameState, commandList) {
    tile.data.primitive.update(context, frameState, commandList);
};


var subtractScratch = new Cesium.Cartesian3();


PCTileProvider.prototype.computeDistanceToTile = function(tile, frameState) {
    var boundingSphere;
    if (frameState.mode === Cesium.SceneMode.SCENE3D) {
        boundingSphere = tile.data.boundingSphere3D;
    } else {
        boundingSphere = tile.data.boundingSphere2D;
    }
    return Math.max(0.0, Cesium.Cartesian3.magnitude(Cesium.Cartesian3.subtract(boundingSphere.center, frameState.camera.positionWC, subtractScratch)) - boundingSphere.radius);
};


PCTileProvider.prototype.isDestroyed = function() {
    return false;
};


PCTileProvider.prototype.destroy = function() {
    return Cesium.destroyObject(this);
};
