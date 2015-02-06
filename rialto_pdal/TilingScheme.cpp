// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

#include "TilingScheme.hpp"


class Buffer {
public:
    Buffer(int l, int x, int y) :
      level(l), tileX(x), tileY(y) {
        return;
    }

    virtual void add(int l, int x, int y, char* data) = 0;

protected:
    int level;
    int tileX;
    int tileY;
};


////////////////////////////////////////////////////////////////////////


// all the points in one tile
class TileBuffer : public Buffer
{
public:
    TileBuffer(int l, int x, int y) : Buffer(l, x, y)
    {
        assert(l != -1);
        assert(x != -1);
        assert(y != -1);
        return;
    }

    void add(int l, int x, int y, char* data)
    {
        assert(l == level);
        assert(x == tileX);
        assert(y == tileY);

        vec.push_back(data);
    }

private:
    // all the points of (a col of a row of a level)
    std::vector<char*> vec; // points
};


//////////////////////////////////////////////////////////////////


// all the cols of (a row of a level)
class RowsBuffer : public Buffer
{
public:
    RowsBuffer(int l, int x, int y) : Buffer(l, x, y)
    {
        assert(l != -1);
        assert(x != -1);
        assert(y == -1);
        return;
    }

    void add(int l, int x, int y, char* data)
    {
        assert(l == level);
        assert(x == tileX);
        assert(-1 == tileY);

        TileBuffer* tile = map[y];
        if (!tile) {
            map.insert( std::pair<int,TileBuffer*>(x, new TileBuffer(l, x, y)) );
            tile = map[y];
        }
        tile->add(l, x, y, data);
    }

private:
    // all the cols of (a row of a level)
    std::map<int, TileBuffer*> map;   // col -> (tile buffer)
};


/////////////////////////////////////////////////////////////////


// all the rows of a level
class LevelBuffer : public Buffer {
public:
    LevelBuffer(int l, int x, int y) : Buffer(l, x, y)
    {
        assert(l != -1);
        assert(x == -1);
        assert(y == -1);
    }

    void add(int l, int x, int y, char* data)
    {
        assert(l == level);
        assert(-1 == tileX);
        assert(-1 == tileY);

        RowsBuffer* rows = map[x];
        if (!rows) {
            map.insert( std::pair<int, RowsBuffer*>(x, new RowsBuffer(l, x, -1)) );
            rows = map[x];
        }
        rows->add(l, x, y, data);
    }

private:
    // all the rows of (a level)
    std::map<int, RowsBuffer*> map;    // row -> (row buffer)
};


//////////////////////////////////////////////////////////////////


// all the levels
class Storage : public Buffer
{
public:
    Storage(int l, int x, int y) : Buffer(l, x, y)
    {
        assert(l == -1);
        assert(x == -1);
        assert(y == -1);
    }

    void add(int l, int x, int y, char* data)
    {
        assert(-1 == level);
        assert(-1 == tileX);
        assert(-1 == tileY);

        LevelBuffer* level = map[l];
        if (!level) {
            map.insert( std::pair<int,LevelBuffer*>(x, new LevelBuffer(l, -1, -1)) );
            level = map[l];
        }
        level->add(l, x, y, data);
    }

private:
    // all the levels
    std::map<int, LevelBuffer*> map;    // level -> (level buffer)

};


//////////////////////////////////////////////////////////////////////////


TilingScheme::TilingScheme(Rectangle& rectangle,
                           boost::uint32_t numberOfLevelZeroTilesX,       // 2
                           boost::uint32_t numberOfLevelZeroTilesY)       // 1
{
    _rectangle = rectangle;
    _numberOfLevelZeroTilesX = numberOfLevelZeroTilesX;
    _numberOfLevelZeroTilesY = numberOfLevelZeroTilesY;
};


const Rectangle& TilingScheme::getRectangle() const
{
    return _rectangle;
}


boost::uint32_t TilingScheme::getNumberOfXTilesAtLevel(boost::uint32_t level) const
{
    return _numberOfLevelZeroTilesX << level;
};


boost::uint32_t TilingScheme::getNumberOfYTilesAtLevel(boost::uint32_t level) const
{
    return _numberOfLevelZeroTilesY << level;
}


Rectangle TilingScheme::rectangleToNativeRectangle(const Rectangle& rectangle) const
{
    boost::uint32_t west = toDegrees(rectangle.west);
    boost::uint32_t south = toDegrees(rectangle.south);
    boost::uint32_t east = toDegrees(rectangle.east);
    boost::uint32_t north = toDegrees(rectangle.north);

    Rectangle result(north, south, east, west);
    return result;
}


Rectangle TilingScheme::tileXYToNativeRectangle(boost::uint32_t x, boost::uint32_t y, boost::uint32_t level) const
{
    Rectangle rectangleRadians = tileXYToRectangle(x, y, level);
    rectangleRadians.west = toDegrees(rectangleRadians.west);
    rectangleRadians.south = toDegrees(rectangleRadians.south);
    rectangleRadians.east = toDegrees(rectangleRadians.east);
    rectangleRadians.north = toDegrees(rectangleRadians.north);
    return rectangleRadians;
}


Rectangle TilingScheme::tileXYToRectangle(boost::uint32_t x, boost::uint32_t y, boost::uint32_t level) const
{
    boost::uint32_t xTiles = getNumberOfXTilesAtLevel(level);
    boost::uint32_t yTiles = getNumberOfYTilesAtLevel(level);

    boost::uint32_t xTileWidth = _rectangle.width() / xTiles;
    boost::uint32_t west = x * xTileWidth + _rectangle.west;
    boost::uint32_t east = (x + 1) * xTileWidth + _rectangle.west;

    boost::uint32_t yTileHeight = _rectangle.height() / yTiles;
    boost::uint32_t north = _rectangle.north - y * yTileHeight;
    boost::uint32_t south = _rectangle.north - (y + 1) * yTileHeight;

    Rectangle result(west, south, east, north);
    return result;
}

 // position in cartographic degrees
 bool TilingScheme::positionToTileXY(double xPosition, double yPosition,
                                     boost::uint32_t& level,
                                     boost::uint32_t& xResult, boost::uint32_t& yResult) const
{
    static const double PI = boost::math::constants::pi<double>();

    if (!_rectangle.contains(xPosition, yPosition)) {
        // outside the bounds of the tiling scheme
        return false;
    }

    boost::uint32_t xTiles = getNumberOfXTilesAtLevel(level);
    boost::uint32_t yTiles = getNumberOfYTilesAtLevel(level);

    boost::uint32_t xTileWidth = _rectangle.width() / xTiles;
    boost::uint32_t yTileHeight = _rectangle.height() / yTiles;

    if (_rectangle.east < _rectangle.west) {
        xPosition += PI * 2.0;
    }

    boost::uint32_t xTileCoordinate = (xPosition - _rectangle.west) / xTileWidth; // TODO: trunc
    if (xTileCoordinate >= xTiles) {
        xTileCoordinate = xTiles - 1;
    }

    boost::uint32_t yTileCoordinate = (_rectangle.north - yPosition) / yTileHeight; // TODO: trunc
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
