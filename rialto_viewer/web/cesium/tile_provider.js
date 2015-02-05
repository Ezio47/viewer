// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


// based on DemoTileProvider from
// https://github.com/AnalyticalGraphicsInc/cesium/blob/master/Specs/Sandcastle/QuadtreePrimitive.html


var DemoTileProvider = function DemoTileProvider(cb) {
    this._quadtree = undefined;
    this._tilingScheme = new Cesium.GeographicTilingScheme();
    this._errorEvent = new Cesium.Event();
    this.callback = cb;
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


DemoTileProvider.prototype.loadTile = function(context, frameState, tile) {

    if (tile.state === Cesium.QuadtreeTileLoadState.START) {
        //console.log(tile.level + " " + tile.x + " " + tile.y);

        var west = Cesium.Math.toDegrees(tile.rectangle.west);
        var south = Cesium.Math.toDegrees(tile.rectangle.south);
        var east = Cesium.Math.toDegrees(tile.rectangle.east);
        var north = Cesium.Math.toDegrees(tile.rectangle.north);

        var p = this.callback(tile.level, tile.x, tile.y,
                              west, south, east, north);

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
        //tile.data.primitive = p;

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
