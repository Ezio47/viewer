// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

#include "TilingScheme.hpp"



//////////////////////////////////////////////////////////////////////////


TilingScheme::TilingScheme(Rectangle& rectangle,
                           int numberOfLevelZeroTilesX,       // 2
                           int numberOfLevelZeroTilesY)       // 1
{
    _rectangle = rectangle;
    _numberOfLevelZeroTilesX = numberOfLevelZeroTilesX;
    _numberOfLevelZeroTilesY = numberOfLevelZeroTilesY;
};


const Rectangle& TilingScheme::getRectangle() const
{
    return _rectangle;
}


int TilingScheme::getNumberOfXTilesAtLevel(int level) const
{
    return _numberOfLevelZeroTilesX << level;
};


int TilingScheme::getNumberOfYTilesAtLevel(int level) const
{
    return _numberOfLevelZeroTilesY << level;
}


Rectangle TilingScheme::rectangleToNativeRectangle(const Rectangle& rectangle) const
{
    double west = toDegrees(rectangle.west);
    double south = toDegrees(rectangle.south);
    double east = toDegrees(rectangle.east);
    double north = toDegrees(rectangle.north);

    Rectangle result(north, south, east, west);
    return result;
}


Rectangle TilingScheme::tileXYToNativeRectangle(int x, int y, int level) const
{
    Rectangle rectangleRadians = tileXYToRectangle(x, y, level);
    
    rectangleRadians.west = toDegrees(rectangleRadians.west);
    rectangleRadians.south = toDegrees(rectangleRadians.south);
    rectangleRadians.east = toDegrees(rectangleRadians.east);
    rectangleRadians.north = toDegrees(rectangleRadians.north);
    
    return rectangleRadians;
}


Rectangle TilingScheme::tileXYToRectangle(int x, int y, int level) const
{
    double xTiles = getNumberOfXTilesAtLevel(level);
    double yTiles = getNumberOfYTilesAtLevel(level);

    double xTileWidth = _rectangle.width() / xTiles;
    double west = x * xTileWidth + _rectangle.west;
    double east = (x + 1.0) * xTileWidth + _rectangle.west;

    double yTileHeight = _rectangle.height() / yTiles;
    double north = _rectangle.north - y * yTileHeight;
    double south = _rectangle.north - (y + 1.0) * yTileHeight;

    Rectangle result(west, south, east, north);
    return result;
}

 // position in cartographic degrees
 bool TilingScheme::positionToTileXY(double xPosition, double yPosition,
                                     int level,
                                     int& xResult, int& yResult) const
{
    static const double PI = boost::math::constants::pi<double>();

    if (!_rectangle.contains(xPosition, yPosition)) {
        // outside the bounds of the tiling scheme
        return false;
    }

    double xTiles = getNumberOfXTilesAtLevel(level);
    double yTiles = getNumberOfYTilesAtLevel(level);

    double xTileWidth = _rectangle.width() / xTiles;
    double yTileHeight = _rectangle.height() / yTiles;

    if (_rectangle.east < _rectangle.west) {
        xPosition += PI * 2.0;
    }

    int xTileCoordinate = (xPosition - _rectangle.west) / xTileWidth; // TODO: trunc
    if (xTileCoordinate >= xTiles) {
        xTileCoordinate = xTiles - 1;
    }

    int yTileCoordinate = (_rectangle.north - yPosition) / yTileHeight; // TODO: trunc
    if (yTileCoordinate >= yTiles) {
        yTileCoordinate = yTiles - 1;
    }

    xResult = xTileCoordinate;
    yResult = yTileCoordinate;

    return true;
}

static const double PI = boost::math::constants::pi<double>();

double TilingScheme::toDegrees(double radians)
{
    return radians * (180.0/PI);
};


double TilingScheme::toRadians(double degrees)
{
    return degrees * (PI/180.0);
};
