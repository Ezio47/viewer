// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


// based on DemoTileProvider from
// https://github.com/AnalyticalGraphicsInc/cesium/blob/master/Specs/Sandcastle/QuadtreePrimitive.html

"use strict";


var assert = function(b, s) {
    if (!b) console.log("***** ERROR: " + s);
}

var PCTileProvider = function PCTileProvider(ppath, creatorCallback, getterCallback) {
    this._quadtree = undefined;
    this._tilingScheme = new Cesium.GeographicTilingScheme();
    this._errorEvent = new Cesium.Event();
    this._tileCreatorCallback = creatorCallback;
    this._tileGetterCallback = getterCallback;
    this._path = ppath;
    this._levelZeroMaximumError = Cesium.QuadtreeTileProvider.computeDefaultLevelZeroMaximumGeometricError(this._tilingScheme);



    this._mytiles = new PCTileTree();

    this._root000 = this._mytiles.createTile(0, 0, 0);
    var url000 = this._path + "/0/0/0.ria";

    this._root010 = this._mytiles.createTile(0, 1, 0);
    var url010 = this._path + "/0/1/0.ria";
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



PCTileProvider.prototype._computeQuadrantOf = function(x, y) {
    var lowX = ((x % 2) == 0);
    var lowY = ((y % 2) == 0);

    if (lowX && lowY) return qNW;
    if (!lowX && lowY) return qNE;
    if (lowX && !lowY) return qSW;
    if (!lowX && !lowY) return qSE;
    assert(false, 1);
};


PCTileProvider.prototype._getXYAtLevel = function(r, l, x, y) {
    while (r != l) {
        l = l - 1;
        x = (x - (x%2)) / 2;
        y = (y - (y%2)) / 2;
    }
    return [l,x,y];
}

// returns a cs state
PCTileProvider.prototype.getStateFromTree = function(root, level, x, y) {
    assert(root != undefined, 3);
    assert(root != null, 4);

    //console.log("getstatefromtree: " + level + x + y);

    if (level == root.level) {
        assert(x == root.x, 5);
        assert(y == root.y, 6);
        return csEXISTS;
    }
    assert(root.level < level, 7);

    if (root.state == tsNOTLOADED) {
        return csUNKNOWN;
    }
    if (root.state == tsLOADING) {
        return csUNKNOWN;
    }

    assert(root.state == tsLOADED, 8);

    var rxy = this._getXYAtLevel(root.level+1, level, x, y);
    //console.log("   rxy=" + rxy[0] + rxy[1] + rxy[2]);
    var q = this._computeQuadrantOf(rxy[1], rxy[2]);
    //console.log("   q=" + q);

    var childState;
    var child;
    if (q == qSW) {
        childState = root.swState;
        child = root.sw;
    } else if (q == qSE) {
        childState = root.seState;
        child = root.se;
    } else if (q == qNW) {
        childState = root.nwState;
        child = root.nw;
    } else if (q == qNE) {
        childState = root.neState;
        child = root.ne;
    } else {
        assert(false, 9);
    }

    if (childState == csDOESNOTEXIST) {
        return csDOESNOTEXIST;
    }

    assert(childState == csEXISTS, 10);
    assert(child != null, 11);

    var ret = this.getStateFromTree(child, level, x, y);
    return ret;
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
        //console.log("START: " + tile.level + " " + tile.x + " " + tile.y);
                //tile.state = Cesium.QuadtreeTileLoadState.DONE;
                //tile.renderable = true;
                //tile.data = {};
                //tile.data.primitive = this._makeRect(tile.rectangle);
                //tile.data.boundingSphere3D = Cesium.BoundingSphere.fromRectangle3D(tile.rectangle);
                //tile.data.boundingSphere2D = Cesium.BoundingSphere.fromRectangle2D(tile.rectangle, frameState.mapProjection);
                //Cesium.Cartesian3.fromElements(tile.data.boundingSphere2D.center.z, tile.data.boundingSphere2D.center.x, tile.data.boundingSphere2D.center.y, tile.data.boundingSphere2D.center);
                //return;

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
        var state = this.getStateFromTree(root, tile.level, tile.x, tile.y);

        //console.log("state " + state + " for " + tile.level + tile.x + tile.y);

        if (state == csUNKNOWN) {
            // nothing we can do, just wait
            return;
        }

        if (state == csDOESNOTEXIST) {
            // no data, do nothing
            tile.data.primitive = this._makeRect(tile.rectangle);
            tile.state = Cesium.QuadtreeTileLoadState.DONE;
            tile.renderable = true;
            return;
        }

        assert(state == csEXISTS, 12);

        var t = this._mytiles.lookupTile(tile.level, tile.x, tile.y);
        if (t == null) {
            //console.log("and creating");
            t = this._mytiles.createTile(tile.level, tile.x, tile.y);
            var url = this._path + "/" + tile.level + "/" + tile.x + "/" + tile.y + ".ria";
            t.loadTileData(this, url);
            return;
        }

        // the tile exists...
        if (t.state == tsLOADING) {
            //console.log("and waiting on loading");
            // just wait
            return;
        }

        // the tile exists...
        if (t.state == tsNOTLOADED) {
            //console.log("and waiting on notloaded");
            var url = this._path + "/" + t.level + "/" + t.x + "/" + t.y + ".ria";
            t.loadTileData(this, url);
            return;
        }

        assert(t.state == tsLOADED, 13);
        //console.log("and continuing");

        this._tileCreatorCallback(tile.level, tile.x, tile.y, west, south, east, north, t.buffer);
        tile.state = Cesium.QuadtreeTileLoadState.LOADING;
    }

    if (tile.state === Cesium.QuadtreeTileLoadState.LOADING) {
        //console.log("LOADINGx: " + tile.level + " " + tile.x + " " + tile.y);// + "(" + tile.data.primitive.ready + ")");

        var t = this._mytiles.lookupTile(tile.level, tile.x, tile.y);
        assert(t != null);

        assert(t.state == tsLOADED);

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
