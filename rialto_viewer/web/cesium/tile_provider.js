// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


// based on DemoTileProvider from
// https://github.com/AnalyticalGraphicsInc/cesium/blob/master/Specs/Sandcastle/QuadtreePrimitive.html

"use strict";

var bouncer = function (f, a) {
    f(a);
};

var assert = function(b, s) {
    if (!b) console.log("***** ERROR: " + s);
}

var DemoTileProvider = function DemoTileProvider(ppath, creatorCallback, getterCallback, stateGetterCallback) {
    this._quadtree = undefined;
    this._tilingScheme = new Cesium.GeographicTilingScheme();
    this._errorEvent = new Cesium.Event();
    this._tileCreatorCallback = creatorCallback;
    this._tileGetterCallback = getterCallback;
    this._tileStateGetterCallback = stateGetterCallback;
    this._path = ppath;
    this._levelZeroMaximumError = Cesium.QuadtreeTileProvider.computeDefaultLevelZeroMaximumGeometricError(this._tilingScheme);

    this._root000 = createTile(0, 0, 0);
    var url000 = this._path + "/0/0/0.ria";
    //loadTileData(this._root000, url000);
    this._root010 = createTile(0, 1, 0);
    var url010 = this._path + "/0/1/0.ria";
    //loadTileData(this._root010, url010);
};


Object.defineProperties(DemoTileProvider.prototype, {
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


DemoTileProvider.prototype.beginUpdate = function(context, frameState, commandList) {
};


DemoTileProvider.prototype.endUpdate = function(context, frameState, commandList) {
};


DemoTileProvider.prototype.getLevelMaximumGeometricError = function(level) {
    return this._levelZeroMaximumError / (1 << level);
};


var makeRect = function(rect) {
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

var mytiles = undefined;

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

var computeQuadrantOf = function(x, y) {
    var lowX = ((x % 2) == 0);
    var lowY = ((y % 2) == 0);

    if (lowX && lowY) return qNW;
    if (!lowX && lowY) return qNE;
    if (lowX && !lowY) return qSW;
    if (!lowX && !lowY) return qSE;
    assert(false, 1);
};


var getXYAtLevel = function(r, l, x, y) {
    while (r != l) {
        l = l - 1;
        x = (x - (x%2)) / 2;
        y = (y - (y%2)) / 2;
    }
    return [l,x,y];
}



var createTile = function(level, x, y) {
    //console.log("creating " + level + x + y);

    if (mytiles == undefined) {
        mytiles = {};
    }
    if (mytiles[level] == undefined) {
        mytiles[level] = {};
    }
    if (mytiles[level][x] == undefined) {
        mytiles[level][x] = {};
    }
    if (mytiles[level][x][y] == undefined) {
        mytiles[level][x][y] = {};
    }
    var t = mytiles[level][x][y];
    t.level = level;
    t.x = x;
    t.y = y;

    t.buffer = null;
    t.state = tsNOTLOADED;

    t.swState = csUNKNOWN;
    t.seState = csUNKNOWN;
    t.nwState = csUNKNOWN;
    t.neState = csUNKNOWN;

    return t;
};

var addTileData = function(t, buffer) {
    //console.log("addding " + t.level + t.x + t.y);

    var level = t.level;
    var x = t.x;
    var y = t.y;

    var bytes = new Uint8Array(buffer);
    var mask = bytes[bytes.length-1];
    //console.log("mask is " + mask);

    t.sw = null;
    t.se = null;
    t.nw = null;
    t.ne = null;

    t.swState = csDOESNOTEXIST;
    t.seState = csDOESNOTEXIST;
    t.nwState = csDOESNOTEXIST;
    t.neState = csDOESNOTEXIST;

    if ((mask & 1) == 1) {
        t.sw = createTile(level+1, 2*x, 2*y+1);
        t.swState = csEXISTS;
    }
    if ((mask & 2) == 2) {
        t.se = createTile(level+1, 2*x+1, 2*y+1);
        t.seState = csEXISTS;
    }
    if ((mask & 4) == 4) {
        t.ne = createTile(level+1, 2*x+1, 2*y);
        t.neState = csEXISTS;
    }
    if ((mask & 8) == 8) {
        t.nw = createTile(level+1, 2*x, 2*y);
        t.nwState = csEXISTS;
    }

    t.buffer = buffer;
};


var lookupTile = function(level, x, y, z) {
    if (mytiles == undefined) return null;
    if (mytiles[level] == undefined) return null;
    if (mytiles[level][x] == undefined) return null;
    if (mytiles[level][x][y] == undefined) return null;
    return mytiles[level][x][y];
};

var loadTileData = function(tile, url) {
    //console.log("loading " + tile.level + tile.x + tile.y);

    assert(tile.state == tsNOTLOADED, 2);
    tile.state = tsLOADING;

    Cesium.loadBlob(url).then(function(blob) {
        //console.log("got blob:" + blob.size);

        var reader = new FileReader();
        reader.addEventListener("loadend", function() {
            var arraybuffer = reader.result;
            addTileData(tile, arraybuffer);
            tile.state = tsLOADED;
        });
        reader.readAsArrayBuffer(blob);

    }).otherwise(function(err) {
        //console.log("FAIL getting blob: " + url);
    });
};

// returns a cs state
var getStateFromTree = function(root, level, x, y) {
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

    var rxy = getXYAtLevel(root.level+1, level, x, y);
    //console.log("   rxy=" + rxy[0] + rxy[1] + rxy[2]);
    var q = computeQuadrantOf(rxy[1], rxy[2]);
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

    var ret = getStateFromTree(child, level, x, y);
    return ret;
};


DemoTileProvider.prototype.loadTile = function(context, frameState, tile) {

    //console.log("PRESTART: " + tile.level + " " + tile.x + " " + tile.y);

    if (tile.state === Cesium.QuadtreeTileLoadState.START) {
        //console.log("START: " + tile.level + " " + tile.x + " " + tile.y);
                //tile.state = Cesium.QuadtreeTileLoadState.DONE;
                //tile.renderable = true;
                //tile.data = {};
                //tile.data.primitive = makeRect(tile.rectangle);
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
        var state = getStateFromTree(root, tile.level, tile.x, tile.y);

        //console.log("state " + state + " for " + tile.level + tile.x + tile.y);

        if (state == csUNKNOWN) {
            // nothing we can do, just wait
            return;
        }

        if (state == csDOESNOTEXIST) {
            // no data, do nothing
            tile.data.primitive = makeRect(tile.rectangle);
            tile.state = Cesium.QuadtreeTileLoadState.DONE;
            tile.renderable = true;
            return;
        }

        assert(state == csEXISTS, 12);

        var t = lookupTile(tile.level, tile.x, tile.y);
        if (t == null) {
            //console.log("and creating");
            t = createTile(tile.level, tile.x, tile.y);
            var url = this._path + "/" + tile.level + "/" + tile.x + "/" + tile.y + ".ria";
            loadTileData(t, url);
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
            loadTileData(t, url);
            return;
        }

        assert(t.state == tsLOADED, 13);
        //console.log("and continuing");

        this._tileCreatorCallback(tile.level, tile.x, tile.y, west, south, east, north, t.buffer);
        tile.state = Cesium.QuadtreeTileLoadState.LOADING;
    }

    if (tile.state === Cesium.QuadtreeTileLoadState.LOADING) {
        //console.log("LOADINGx: " + tile.level + " " + tile.x + " " + tile.y);// + "(" + tile.data.primitive.ready + ")");

        var pp = null;

        var st = this._tileStateGetterCallback(tile.level, tile.x, tile.y);
        if (st == 1) {
            // tile does not exist on disk
            //console.log("--> 1");
            if (tile.data.primitive == null) {
                tile.data.primitive = makeRect(tile.rectangle);
            }

        } else if (st == 2) {
            // tile exists, but is empty and so will never have a primitive
            //console.log("--> 2");
            if (tile.data.primitive == null) {
                tile.data.primitive = makeRect(tile.rectangle);
            }

        } else if (st == 3) {
            // tile exists and has points, but primitive not yet built
            //console.log("--> 3");

            if (tile.data.primitive == null) {
                tile.data.primitive = this._tileGetterCallback(tile.level, tile.x, tile.y);
            }
            return;

        } else {
            // tile exists has (or will have) a primitive
            //console.log("--> 4");

            if (st != 4) {
                console.log("ERROR: bad tile state");
                return;
            }

            if (tile.data.primitive == null) {
                tile.data.primitive = this._tileGetterCallback(tile.level, tile.x, tile.y);
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


DemoTileProvider.prototype.computeTileVisibility = function(tile, frameState, occluders) {
    var boundingSphere;
    if (frameState.mode === Cesium.SceneMode.SCENE3D) {
        boundingSphere = tile.data.boundingSphere3D;
    } else {
        boundingSphere = tile.data.boundingSphere2D;
    }
    return frameState.cullingVolume.computeVisibility(boundingSphere);
};


DemoTileProvider.prototype.showTileThisFrame = function(tile, context, frameState, commandList) {
    tile.data.primitive.update(context, frameState, commandList);
};


var subtractScratch = new Cesium.Cartesian3();


DemoTileProvider.prototype.computeDistanceToTile = function(tile, frameState) {
    var boundingSphere;
    if (frameState.mode === Cesium.SceneMode.SCENE3D) {
        boundingSphere = tile.data.boundingSphere3D;
    } else {
        boundingSphere = tile.data.boundingSphere2D;
    }
    return Math.max(0.0, Cesium.Cartesian3.magnitude(Cesium.Cartesian3.subtract(boundingSphere.center, frameState.camera.positionWC, subtractScratch)) - boundingSphere.radius);
};


DemoTileProvider.prototype.isDestroyed = function() {
    return false;
};


DemoTileProvider.prototype.destroy = function() {
    return Cesium.destroyObject(this);
};
