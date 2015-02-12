// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


"use strict";


var PCTileTree = function PCTileTree() {
    this._mytiles = undefined;
};


PCTileTree.prototype.lookupTile = function(level, x, y, z) {
    if (this._mytiles == undefined) return null;
    if (this._mytiles[level] == undefined) return null;
    if (this._mytiles[level][x] == undefined) return null;
    if (this._mytiles[level][x][y] == undefined) return null;
    return this._mytiles[level][x][y];
};


PCTileTree.prototype.createTile = function(level, x, y) {
    //console.log("creating " + level + x + y);

    if (this._mytiles == undefined) {
        this._mytiles = {};
    }
    if (this._mytiles[level] == undefined) {
        this._mytiles[level] = {};
    }
    if (this._mytiles[level][x] == undefined) {
        this._mytiles[level][x] = {};
    }
    //if (this._mytiles[level][x][y] == undefined) {
    //    this._mytiles[level][x][y] = {};
    //}

    var t = new PCTile(this, level, x, y);

    this._mytiles[level][x][y] = t;

    return t;
};

