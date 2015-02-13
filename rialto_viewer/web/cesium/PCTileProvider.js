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


var PCTileProvider = function PCTileProvider(urlPath) {
    "use strict";

    this._quadtree = undefined;
    this._tilingScheme = new Cesium.GeographicTilingScheme();
    this._errorEvent = new Cesium.Event();
    this._levelZeroMaximumError = Cesium.QuadtreeTileProvider.computeDefaultLevelZeroMaximumGeometricError(this._tilingScheme);

    this._urlPath = urlPath;
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

    for (i = 0; i < dims.length; i += 1) {

        dims[i].offset = tot;

        switch (dims[i].datatype) {

        case "uint8_t":
        case "int8_t":
            tot += 1;
            break;
        case "uint16_t":
        case "int16_t":
            tot += 2;
            break;
        case "uint32_t":
        case "int32_t":
            tot += 4;
            break;
        case "uint64_t":
        case "int64_t":
            tot += 8;
            break;
        case "float":
            tot += 4;
            break;
        case "double":
            tot += 8;
            break;
        default:
            assert(false);
        }
    }

    return tot;
};


PCTileProvider.prototype.readHeader = function () {
    "use strict";

    var provider = this;

    var url = this._urlPath + "/header.json";

    Cesium.loadJson(url).then(function (json) {
        provider.header = json;
        provider._ready = true;
        provider.pointSizeInBytes = provider._computePointSize();
        console.log("point size: " + provider.pointSizeInBytes);

        provider._tiletree = new PCTileTree(provider._urlPath, provider);

        provider._root000 = provider._tiletree.createTile(0, 0, 0);
        provider._root010 = provider._tiletree.createTile(0, 1, 0);

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

    if (false) {
        tile.data = {
                    primitive : undefined,
                    freeResources : function () {
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

        tile.data.primitive = this._makeRect(tile.rectangle); //pcTile.primitive;
        tile.state = Cesium.QuadtreeTileLoadState.DONE;
        tile.renderable = true;
        return;
    }

  //  console.log("PRESTART: " + tile.level + " " + tile.x + " " + tile.y);

    if (tile.state === Cesium.QuadtreeTileLoadState.START) {

        var west = Cesium.Math.toDegrees(tile.rectangle.west);
        var south = Cesium.Math.toDegrees(tile.rectangle.south);
        var east = Cesium.Math.toDegrees(tile.rectangle.east);
        var north = Cesium.Math.toDegrees(tile.rectangle.north);

        tile.data = {
            primitive : undefined,
            freeResources : function () {
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

        var root = (west < 0) ? this._root000 : this._root010;
        var pcTileState = this._tiletree.getTileState(root, tile.level, tile.x, tile.y);

      //  console.log("state " + pcTileState + " for " + tile.level + tile.x + tile.y);

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
            tile.state = Cesium.QuadtreeTileLoadState.LOADING;
            pcTile = this._tiletree.createTile(tile.level, tile.x, tile.y);
            pcTile.loadTileData();
            return;
        }

        // the tile exists...
        if (pcTile.state == tsLOADING) {
            //console.log("and waiting on loading");
            // just wait
            tile.state = Cesium.QuadtreeTileLoadState.LOADING;
            return;
        }

        // the tile exists...
        if (pcTile.state == tsNOTLOADED) {
            //console.log("and waiting on notloaded");
            tile.state = Cesium.QuadtreeTileLoadState.LOADING;
            pcTile.loadTileData();
            return;
        }

        assert(pcTile.state == tsLOADED, 13);
        //console.log("and continuing");

        tile.state = Cesium.QuadtreeTileLoadState.LOADING;
    }

    if (tile.state === Cesium.QuadtreeTileLoadState.LOADING) {
      //  console.log("LOADINGx: " + tile.level + " " + tile.x + " " + tile.y);

        var pcTile = this._tiletree.lookupTile(tile.level, tile.x, tile.y);
        assert(pcTile != null, 55);

        if (pcTile.state != tsLOADED) {
          //  console.log("not loaded, go around");
            return;
        }

        assert(pcTile.state == tsLOADED);

        tile.data.primitive = pcTile.primitive;

        if (tile.data.primitive == null) {
            // tile w/ no data in it
            console.log("no data in it");
            tile.state = Cesium.QuadtreeTileLoadState.DONE;
            tile.renderable = false;
            return;
        }

        assert(tile.data.primitive != null);

        //tile.data.primitive = this._makeRect(tile.rectangle);

        //tile.data.primitive.update(context, frameState, []);
        //console.log("LOADINGy: " + tile.level + " " + tile.x + " " + tile.y + "(" + tile.data.primitive._state + ")");
        //if (tile.data.primitive.ready) {
            //console.log("LOADINGz: " + tile.level + " " + tile.x + " " + tile.y);
            tile.state = Cesium.QuadtreeTileLoadState.DONE;
            tile.renderable = true;
        //}

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
