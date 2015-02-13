// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


var PCTileTree = function PCTileTree(urlPath, provider) {
    "use strict";

    this._urlPath = urlPath;
    this.header = provider.header;
    this.provider = provider;
    this._tiles = undefined;
};


PCTileTree.prototype.getUrl = function (pcTile) {
    "use strict";

    var url = this._urlPath + "/" + pcTile.level + "/" + pcTile.x + "/" + pcTile.y + ".ria";
    return url;
};


PCTileTree.prototype.lookupTile = function (level, x, y) {
    "use strict";

    if (this._tiles == undefined) {
        return null;
    }
    if (this._tiles[level] == undefined) {
        return null;
    }
    if (this._tiles[level][x] == undefined) {
        return null;
    }
    if (this._tiles[level][x][y] == undefined) {
        return null;
    }

    return this._tiles[level][x][y];
};


PCTileTree.prototype.createTile = function (level, x, y) {
    "use strict";

    //console.log("creating " + level + x + y);

    if (this._tiles == undefined) {
        this._tiles = {};
    }
    if (this._tiles[level] == undefined) {
        this._tiles[level] = {};
    }
    if (this._tiles[level][x] == undefined) {
        this._tiles[level][x] = {};
    }
    //if (this._tiles[level][x][y] == undefined) {
    //    this._tiles[level][x][y] = {};
    //}

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

    assert(false, 1);
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

    var rxy = this.getXYAtLevel(root.level + 1, level, x, y);
    //console.log("   rxy=" + rxy[0] + rxy[1] + rxy[2]);
    var q = this.computeQuadrantOf(rxy[1], rxy[2]);
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

    var ret = this.getTileState(child, level, x, y);
    return ret;
};
