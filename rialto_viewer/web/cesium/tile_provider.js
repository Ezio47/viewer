// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


// based on DemoTileProvider from
// https://github.com/AnalyticalGraphicsInc/cesium/blob/master/Specs/Sandcastle/QuadtreePrimitive.html

var bouncer = function(f,a) {
    f(a);
}

var DemoTileProvider = function DemoTileProvider(creatorCallback, getterCallback, stateGetterCallback) {
    this._quadtree = undefined;
    this._tilingScheme = new Cesium.GeographicTilingScheme();
    this._errorEvent = new Cesium.Event();
    this._tileCreatorCallback = creatorCallback;
    this._tileGetterCallback = getterCallback;
    this._tileStateGetterCallback = stateGetterCallback;
    this._levelZeroMaximumError = Cesium.QuadtreeTileProvider.computeDefaultLevelZeroMaximumGeometricError(this._tilingScheme);
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
}


DemoTileProvider.prototype.loadTile = function(context, frameState, tile) {

    if (tile.state === Cesium.QuadtreeTileLoadState.START) {
        //console.log("START: " + tile.level + " " + tile.x + " " + tile.y);

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

        this._tileCreatorCallback(tile.level, tile.x, tile.y, west, south, east, north);

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
            // tile exists and has (or will have) a primitive
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
