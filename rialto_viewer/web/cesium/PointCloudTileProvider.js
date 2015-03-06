//
// options:
//   url
//   proxy
//
var PointCloudTileProvider = function PointCloudTileProvider(options) {
    "use strict";

    if (!defined(options) || !defined(options.url)) {
        throw new DeveloperError('options.url is required.');
    }

    this._url = appendForwardSlash(options.url);
    this._proxy = options.proxy;

    this._tilingScheme = new GeographicTilingScheme({
        numberOfLevelZeroTilesX : 2,
        numberOfLevelZeroTilesY : 1
    });

    /* this._levelZeroMaximumGeometricError = ... */

    this._errorEvent = new Event();

    this._ready = false;

    var metadataUrl = this._url + 'header.json';
    if (defined(this._proxy)) {
        metadataUrl = this._proxy.getURL(metadataUrl);
    }

    var that = this;
    var metadataError;

    function metadataSuccess(data) {
        var message;

        // here we do any sanity checking on the `data` object
        // if error:
        //    message = '...';
        //    metadataError = TileProviderError.handleError(metadataError, that, that._errorEvent, message, undefined, undefined, undefined, requestMetadata);
        //    return;

        var baseUri = new Uri(metadataUrl);

        that._tileUrlTemplates = data.tiles;
        for (var i = 0; i < that._tileUrlTemplates.length; ++i) {
            that._tileUrlTemplates[i] = new Uri(that._tileUrlTemplates[i]).resolve(baseUri).toString().replace('{version}', data.version);
        }

        /* that._availableTiles = data.available; */

        that._ready = true;
    }

    function metadataFailure(data) {
        var message = 'An error occurred while accessing ' + metadataUrl + '.';
        metadataError = TileProviderError.handleError(metadataError, that, that._errorEvent, message, undefined, undefined, undefined, requestMetadata);
    }

    function requestMetadata() {
        var metadata = loadJson(metadataUrl);
        when(metadata, metadataSuccess, metadataFailure);
    }

    requestMetadata();
};



PointCloudTileProvider.prototype._getRequestHeader = function(extensionsList) {
    if (!defined(extensionsList) || extensionsList.length === 0) {
        return {
            Accept : 'application/vnd.quantized-mesh,application/octet-stream;q=0.9,*/*;q=0.01'
        };
    } else {
        var extensions = extensionsList.join('-');
        return {
            Accept : 'application/vnd.quantized-mesh;extensions=' + extensions + ',application/octet-stream;q=0.9,*/*;q=0.01'
        };
    }
}


PointCloudTileProvider.prototype._createPointCloudTileData = function(provider, buffer, level, x, y, tmsY) {
    var heightBuffer = new Uint16Array(buffer, 0, provider._heightmapWidth * provider._heightmapWidth);

    return new PointCloudTileData({
        buffer : heightBuffer,
        childTileMask : new Uint8Array(buffer, heightBuffer.byteLength, 1)[0],
        width : provider._heightmapWidth,
        height : provider._heightmapWidth,
        structure : provider._heightmapStructure
    });
}


PointCloudTileProvider.prototype.requestTileGeometry = function(x, y, level, throttleRequests) {
    if (!this._ready) {
        throw new DeveloperError('requestTileGeometry must not be called before the tile provider is ready.');
    }

    var urlTemplates = this._tileUrlTemplates;
    if (urlTemplates.length === 0) {
        return undefined;
    }

    var yTiles = this._tilingScheme.getNumberOfYTilesAtLevel(level);

    var tmsY = (yTiles - y - 1);

    // Use the first URL template.  In the future we should use them all.
    var url = urlTemplates[0].replace('{z}', level).replace('{x}', x).replace('{y}', tmsY);

    var proxy = this._proxy;
    if (defined(proxy)) {
        url = proxy.getURL(url);
    }

    var promise;

    var tileLoader = function(tileUrl) {
        return loadArrayBuffer(tileUrl, getRequestHeader(extensionList));
    };

    throttleRequests = defaultValue(throttleRequests, true);
    if (throttleRequests) {
        promise = throttleRequestByServer(url, tileLoader);
        if (!defined(promise)) {
            return undefined;
        }
    } else {
        promise = tileLoader(url);
    }

    var that = this;
    return when(promise, function(buffer) {
        if (defined(that._heightmapStructure)) {
            return createPointCloudData(that, buffer, level, x, y, tmsY);
        }
    });
};


Object.defineProperties(PointCloudTileProvider.prototype, {

    errorEvent : {
        get : function() {
            return this._errorEvent;
        }
    },

    tilingScheme : {
        get : function() {
            if (!this._ready) {
                throw new DeveloperError('tilingScheme must not be called before the terrain provider is ready.');
            }

            return this._tilingScheme;
        }
    },

    ready : {
        get : function() {
            return this._ready;
        }
    }
});


PointCloudTileProvider.prototype.getLevelMaximumGeometricError = function(level) {
    return this._levelZeroMaximumGeometricError / (1 << level);
};


PointCloudTileProvider.prototype._getChildMaskForTile = function (terrainProvider, level, x, y) {
    var available = terrainProvider._availableTiles;
    if (!available || available.length === 0) {
        return 15;
    }

    var childLevel = level + 1;
    if (childLevel >= available.length) {
        return 0;
    }

    var levelAvailable = available[childLevel];

    var mask = 0;

    mask |= isTileInRange(levelAvailable, 2 * x, 2 * y) ? 1 : 0;
    mask |= isTileInRange(levelAvailable, 2 * x + 1, 2 * y) ? 2 : 0;
    mask |= isTileInRange(levelAvailable, 2 * x, 2 * y + 1) ? 4 : 0;
    mask |= isTileInRange(levelAvailable, 2 * x + 1, 2 * y + 1) ? 8 : 0;

    return mask;
}


PointCloudTileProvider.prototype._isTileInRange = function(levelAvailable, x, y) {
    for (var i = 0, len = levelAvailable.length; i < len; ++i) {
        var range = levelAvailable[i];
        if (x >= range.startX && x <= range.endX && y >= range.startY && y <= range.endY) {
            return true;
        }
    }

    return false;
}


PointCloudTileProvider.prototype.getTileDataAvailable = function(x, y, level) {
    var available = this._availableTiles;

    if (!available || available.length === 0) {
        return undefined;
    } else {
        if (level >= available.length) {
            return false;
        }
        var levelAvailable = available[level];
        var yTiles = this._tilingScheme.getNumberOfYTilesAtLevel(level);
        var tmsY = (yTiles - y - 1);
        return isTileInRange(levelAvailable, x, tmsY);
    }
};
