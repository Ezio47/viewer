var PointCloudTileData = function PointCloudTileData(dataview, childMask, header) {
    "use strict";
    this._dataview = dataview;
    this._childMask = childMask;

    this._header = header;

    this.numPoints = 0;

    this._buildDimensionArrays();
};


PointCloudTileData.prototype._buildDimensionArrays = function () {
    "use strict";

    var numBytes = this._dataview.byteLength;

    var headerDims = this._header.dimensions;
    var i;
    var datatype,
        offset,
        stride,
        name,
        v;

    if (numBytes == 0) {
        this.numPoints = 0;
    } else {
        this.numPoints = numBytes / this._header.pointSizeInBytes;
        myassert(this.numPoints * this._header.pointSizeInBytes == numBytes, 71);
    }

    this.dimensions = {};

    mylog("num points in tile: " + this.numPoints);

    for (i = 0; i < headerDims.length; i += 1) {
        datatype = headerDims[i].datatype;
        offset = headerDims[i].offset;
        name = headerDims[i].name;
        stride = this._header.pointSizeInBytes;

        if (this.numPoints == 0) {
            v = null;
        } else {
            v = this._extractDimensionArray(this._dataview, datatype, offset, stride, this.numPoints);
        }
        this.dimensions[name] = v;
    }

   // this is the array used to colorize each point
    var rgba = new Uint8Array(this.numPoints * 4);
    for (i = 0; i < this.numPoints * 4; i += 1) {
        rgba[i] = 255;
    }
    name = "rgba";
    this.dimensions[name] = rgba;
};


// Dataview is an array-of-structs: x0, y0, z0, t0, x1, y1, ...
// Create an array of all the elements from one of the struct fields
PointCloudTileData.prototype._extractDimensionArray = function (dataview, datatype, offset, stride, len) {
    "use strict";

    var dst, dstIndex, dvIndex;

    switch (datatype) {
    case "uint8_t":
        dst = new Uint8Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getUint8(dvIndex);
        }
        break;
    case "int8_t":
        dst = new Int8Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getInt8(dvIndex);
        }
        break;
    case "uint16_t":
        dst = new Uint16Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getUint16(dvIndex, true);
        }
        break;
    case "int16_t":
        dst = new Int16Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getInt16(dvIndex, true);
        }
        break;
    case "uint32_t":
        dst = new Uint32Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getUint32(dvIndex, true);
        }
        break;
    case "int32_t":
        dst = new Int32Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getInt32(dvIndex, true);
        }
        break;
    case "uint64_t":
        dst = new Uint64Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getUint64(dvIndex, true);
        }
        break;
    case "int64_t":
        dst = new Int64Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getInt64(dvIndex, true);
        }
        break;
    case "float":
        dst = new Float32Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getFloat32(dvIndex, true);
        }
        break;
    case "double":
        dst = new Float64Array(len);
        for (dstIndex = 0, dvIndex = offset; dstIndex < len; dstIndex += 1, dvIndex += stride) {
            dst[dstIndex] = dataview.getFloat64(dvIndex, true);
        }
        break;
    default:
        myassert(false, 70);
        break;
    }
    return dst;
};


Object.defineProperties(PointCloudTileData.prototype, {
    waterMask : {
        get : function() {
            return this._waterMask;
        }
    }
});


var taskProcessor = new Cesium.TaskProcessor('createVerticesFromPointCloudTile');



    /**
     * Creates a {@link TerrainMesh} from this terrain data.
     *
     * @param {TilingScheme} tilingScheme The tiling scheme to which this tile belongs.
     * @param {Number} x The X coordinate of the tile for which to create the terrain data.
     * @param {Number} y The Y coordinate of the tile for which to create the terrain data.
     * @param {Number} level The level of the tile for which to create the terrain data.
     * @returns {Promise|TerrainMesh} A promise for the terrain mesh, or undefined if too many
     *          asynchronous mesh creations are already in progress and the operation should
     *          be retried later.
     */
    PointCloudTileData.prototype.createMesh = function(tilingScheme, x, y, level) {
        "use strict";

        if (!Cesium.defined(tilingScheme)) {
            throw new Cesium.DeveloperError('tilingScheme is required.');
        }
        if (!Cesium.defined(x)) {
            throw new Cesium.DeveloperError('x is required.');
        }
        if (!Cesium.defined(y)) {
            throw new Cesium.DeveloperError('y is required.');
        }
        if (!Cesium.defined(level)) {
            throw new Cesium.DeveloperError('level is required.');
        }

        var ellipsoid = tilingScheme.ellipsoid;
        var nativeRectangle = tilingScheme.tileXYToNativeRectangle(x, y, level);
        var rectangle = tilingScheme.tileXYToRectangle(x, y, level);

        // Compute the center of the tile for RTC rendering.
        var center = ellipsoid.cartographicToCartesian(Rectangle.center(rectangle));

        var structure = this._structure;

        var levelZeroMaxError = TerrainProvider.getEstimatedLevelZeroGeometricErrorForAHeightmap(ellipsoid, this._width, tilingScheme.getNumberOfXTilesAtLevel(0));
        var thisLevelMaxError = levelZeroMaxError / (1 << level);

        var verticesPromise = taskProcessor.scheduleTask({
            heightmap : this._buffer,
            structure : structure,
            width : this._width,
            height : this._height,
            nativeRectangle : nativeRectangle,
            rectangle : rectangle,
            relativeToCenter : center,
            ellipsoid : ellipsoid,
            skirtHeight : Math.min(thisLevelMaxError * 4.0, 1000.0),
            isGeographic : tilingScheme instanceof GeographicTilingScheme
        });

        if (!Cesium.defined(verticesPromise)) {
            // Postponed
            return undefined;
        }

        return Cesium.when(verticesPromise, function(result) {
            return new TerrainMesh(
                    center,
                    new Float32Array(result.vertices),
                    TerrainProvider.getRegularGridIndices(result.gridWidth, result.gridHeight),
                    result.minimumHeight,
                    result.maximumHeight,
                    result.boundingSphere3D,
                    result.occludeePointInScaledSpace);
        });
    };



    PointCloudTileData.prototype.isChildAvailable = function(thisX, thisY, childX, childY) {
        "use strict";

        if (!Cesium.defined(thisX)) {
            throw new Cesium.DeveloperError('thisX is required.');
        }
        if (!Cesium.defined(thisY)) {
            throw new Cesium.DeveloperError('thisY is required.');
        }
        if (!Cesium.defined(childX)) {
            throw new Cesium.DeveloperError('childX is required.');
        }
        if (!Cesium.defined(childY)) {
            throw new Cesium.DeveloperError('childY is required.');
        }

        var bitNumber = 2; // northwest child
        if (childX !== thisX * 2) {
            ++bitNumber; // east child
        }
        if (childY !== thisY * 2) {
            bitNumber -= 2; // south child
        }

        return (this._childTileMask & (1 << bitNumber)) !== 0;
    };
