// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


TilingScheme::TilingScheme(Rectangle& rectangle,
                           boost::uint32 numberOfLevelZeroTilesX,       // 2
                           boost::uint32 numberOfLevelZeroTilesY)       // 1
{
    _rectangle = rectangle;
    _numberOfLevelZeroTilesX = numberOfLevelZeroTilesX;
    _numberOfLevelZeroTilesY = numberOfLevelZeroTilesY;
};


const Rectangle& TilingScheme::getRectangle() const
{
    return _rectangle;
}


int TilingScheme::getNumberOfXTilesAtLevel(boost::uint32 level)
{
    return _numberOfLevelZeroTilesX << level;
};


int TilingScheme::getNumberOfYTilesAtLevel(boost::uint32 level)
{
    return _numberOfLevelZeroTilesY << level;
}


GeographicTilingScheme::rectangleToNativeRectangle(const Rectangle& rectangle) const
{    
    var west = CesiumMath.toDegrees(rectangle.west);
    var south = CesiumMath.toDegrees(rectangle.south);
    var east = CesiumMath.toDegrees(rectangle.east);
    var north = CesiumMath.toDegrees(rectangle.north);
    
    if (!defined(result)) {
        return new Rectangle(west, south, east, north);
    }
    
    result.west = west;
    result.south = south;
    result.east = east;
    result.north = north;
    return result;
}


Rectangle TilingScheme::tileXYToNativeRectangle(boost:uint32 x, boost:uint32 y, boost:uint32 level) const
{
    var rectangleRadians = this.tileXYToRectangle(x, y, level, result);
    rectangleRadians.west = CesiumMath.toDegrees(rectangleRadians.west);
    rectangleRadians.south = CesiumMath.toDegrees(rectangleRadians.south);
    rectangleRadians.east = CesiumMath.toDegrees(rectangleRadians.east);
    rectangleRadians.north = CesiumMath.toDegrees(rectangleRadians.north);
    return rectangleRadians;
}

 
Rectangle TilingScheme::tileXYToRectangle(boost:uint32 x, boost:uint32 y, boost:uint32 level) const
    var rectangle = this._rectangle;
    
    var xTiles = this.getNumberOfXTilesAtLevel(level);
    var yTiles = this.getNumberOfYTilesAtLevel(level);
    
    var xTileWidth = rectangle.width / xTiles;
    var west = x * xTileWidth + rectangle.west;
    var east = (x + 1) * xTileWidth + rectangle.west;
    
    var yTileHeight = rectangle.height / yTiles;
    var north = rectangle.north - y * yTileHeight;
    var south = rectangle.north - (y + 1) * yTileHeight;
    
    if (!defined(result)) {
        result = new Rectangle(west, south, east, north);
    }
    
    result.west = west;
    result.south = south;
    result.east = east;
    result.north = north;
    return result;
}

 // position in cartographic degrees
 void TilingScheme::positionToTileXY(double xPosition, double yPosition,
                                     boost::uint32& level,
                                     boost::uint32& xResult, boost::uint32& yResult)
{
    var rectangle = this._rectangle;
    if (!Rectangle.contains(rectangle, position)) {
        // outside the bounds of the tiling scheme
        return undefined;
    }

    var xTiles = this.getNumberOfXTilesAtLevel(level);
    var yTiles = this.getNumberOfYTilesAtLevel(level);

    var xTileWidth = rectangle.width / xTiles;
    var yTileHeight = rectangle.height / yTiles;

    var longitude = position.longitude;
    if (rectangle.east < rectangle.west) {
        longitude += CesiumMath.TWO_PI;
    }

    var xTileCoordinate = (longitude - rectangle.west) / xTileWidth | 0;
    if (xTileCoordinate >= xTiles) {
        xTileCoordinate = xTiles - 1;
    }

    var yTileCoordinate = (rectangle.north - position.latitude) / yTileHeight | 0;
    if (yTileCoordinate >= yTiles) {
        yTileCoordinate = yTiles - 1;
    }

    if (!defined(result)) {
        return new Cartesian2(xTileCoordinate, yTileCoordinate);
    }

    result.x = xTileCoordinate;
    result.y = yTileCoordinate;
    return result;
}
