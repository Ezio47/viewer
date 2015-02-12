// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


"use strict";


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


var PCTile = function PCTile(tree, level, x, y) {
    this._tree = tree;

    this._level = level;
    this._x = x;
    this._y = y;

    this.buffer = null;
    this.state = tsNOTLOADED;

    this.swState = csUNKNOWN;
    this.seState = csUNKNOWN;
    this.nwState = csUNKNOWN;
    this.neState = csUNKNOWN;

    this.sw = undefined;
    this.se = undefined;
    this.nw = undefined;
    this.ne = undefined;
};


Object.defineProperties(PCTile.prototype, {
    level : {
        get : function() {
            return this._level;
        }
    },
    x : {
        get : function() {
            return this._x;
        }
    },
    y : {
        get : function() {
            return this._y;
        }
    }
});


PCTile.prototype.addTileData = function(buffer) {
    //console.log("addding " + t.level + t.x + t.y);

    var level = this.level;
    var x = this.x;
    var y = this.y;

    var bytes = new Uint8Array(buffer);
    var mask = bytes[bytes.length-1];
    //console.log("mask is " + mask);

    this.sw = null;
    this.se = null;
    this.nw = null;
    this.ne = null;

    this.swState = csDOESNOTEXIST;
    this.seState = csDOESNOTEXIST;
    this.nwState = csDOESNOTEXIST;
    this.neState = csDOESNOTEXIST;

    if ((mask & 1) == 1) {
        this.sw = this._tree.createTile(level+1, 2*x, 2*y+1);
        this.swState = csEXISTS;
    }
    if ((mask & 2) == 2) {
        this.se = this._tree.createTile(level+1, 2*x+1, 2*y+1);
        this.seState = csEXISTS;
    }
    if ((mask & 4) == 4) {
        this.ne = this._tree.createTile(level+1, 2*x+1, 2*y);
        this.neState = csEXISTS;
    }
    if ((mask & 8) == 8) {
        this.nw = this._tree.createTile(level+1, 2*x, 2*y);
        this.nwState = csEXISTS;
    }

    this.buffer = buffer;
};


PCTile.prototype.loadTileData = function() {
    //console.log("loading " + this.level + this.x + this.y);

    var url = this._tree.getUrl(this);

    assert(this.state == tsNOTLOADED, 2);
    this.state = tsLOADING;

    var thisTile = this;

    Cesium.loadBlob(url).then(function(blob) {
        //console.log("got blob:" + blob.size);

        var reader = new FileReader();
        reader.addEventListener("loadend", function() {
            var arraybuffer = reader.result;
            thisTile.addTileData(arraybuffer);
            thisTile.state = tsLOADED;
        });
        reader.readAsArrayBuffer(blob);

    }).otherwise(function(err) {
        //console.log("FAIL getting blob: " + url);
    });
};

