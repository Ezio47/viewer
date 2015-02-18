// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


var PCTileTree = function PCTileTree(provider) {
    "use strict";

    this.header = provider.header;
    this.provider = provider;
    this._tiles = undefined;
};


PCTileTree.prototype.lookupPCTile = function (tile) {
    "use strict";

    if (this._tiles == undefined) {
        return null;
    }

    var level = tile.level;
    if (this._tiles[level] == undefined) {
        return null;
    }

    var x = tile.x;
    if (this._tiles[level][x] == undefined) {
        return null;
    }

    var y = tile.y;
    if (this._tiles[level][x][y] == undefined) {
        return null;
    }

    return this._tiles[level][x][y];
};


PCTileTree.prototype.createPCTile = function (level, x, y) {
    "use strict";

    //mylog("creating " + level + x + y);

    if (this._tiles == undefined) {
        this._tiles = {};
    }
    if (this._tiles[level] == undefined) {
        this._tiles[level] = {};
    }
    if (this._tiles[level][x] == undefined) {
        this._tiles[level][x] = {};
    }

    var pcTile = new PCTile(this, level, x, y);

    this._tiles[level][x][y] = pcTile;

    return pcTile;
};


PCTileTree.prototype.computeQuadrantOf = function (x, y) {
    "use strict";

    var lowX = ((x % 2) == 0);
    var lowY = ((y % 2) == 0);

    if (lowX && lowY) {
        return qNW;
    }
    if (!lowX && lowY) {
        return qNE;
    }
    if (lowX && !lowY) {
        return qSW;
    }
    if (!lowX && !lowY) {
        return qSE;
    }

    myassert(false, 1);
};


PCTileTree.prototype.getXYAtLevel = function (r, l, x, y) {
    "use strict";

    while (r != l) {
        l = l - 1;
        x = (x - (x % 2)) / 2;
        y = (y - (y % 2)) / 2;
    }
    return [l, x, y];
};


// returns a cs state
PCTileTree.prototype.getTileState = function (root, level, x, y) {
    "use strict";

    myassert(root != undefined, 3);
    myassert(root != null, 4);

    //mylog("getstatefromtree: " + level + x + y);

    if (level == root.level) {
        myassert(x == root.x, 5);
        myassert(y == root.y, 6);
        return csEXISTS;
    }
    myassert(root.level < level, 7);

    if (root.state == tsNOTLOADED) {
        return csUNKNOWN;
    }
    if (root.state == tsLOADING) {
        return csUNKNOWN;
    }

    myassert(root.state == tsLOADED, 8);

    var xyzRoot = this.getXYAtLevel(root.level + 1, level, x, y);
    var quadrant = this.computeQuadrantOf(xyzRoot[1], xyzRoot[2]);

    var childState;
    var child;
    if (quadrant == qSW) {
        childState = root.swState;
        child = root.sw;
    } else if (quadrant == qSE) {
        childState = root.seState;
        child = root.se;
    } else if (quadrant == qNW) {
        childState = root.nwState;
        child = root.nw;
    } else if (quadrant == qNE) {
        childState = root.neState;
        child = root.ne;
    } else {
        myassert(false, 9);
    }

    if (childState == csDOESNOTEXIST) {
        return csDOESNOTEXIST;
    }

    myassert(childState == csEXISTS, 10);
    myassert(child != null, 11);

    var ret = this.getTileState(child, level, x, y);
    return ret;
};
