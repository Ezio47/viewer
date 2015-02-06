// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

#ifndef BUFFER_HPP
#define BUFFER_HPP

#include <pdal/PipelineManager.hpp>
#include <boost/math/constants/constants.hpp>

#include "Rectangle.hpp"
#include "Tile.hpp"


//-------------------------------------------------------------------


class Buffer {
public:
    Buffer(int l, int x, int y);
    virtual ~Buffer();
    
    virtual Tile* get(int l, int x, int y) = 0;
    virtual Tile* add(int l, int x, int y) = 0;
    virtual void dump(int indent) = 0;

    int level;
    int tileX;
    int tileY;
};


//-------------------------------------------------------------------


// all the cols of (a row of a level)
class RowsBuffer : public Buffer
{
public:
    RowsBuffer(int l, int y);
    virtual ~RowsBuffer();
    
    virtual Tile* get(int l, int x, int y);
    virtual Tile* add(int l, int x, int y);
    virtual void dump(int indent);

private:
    // all the cols of (a row of a level)
    std::map<int, Tile*> map;   // col -> (tile buffer)

    int lastLevel;
    int lastTileX;
    int lastTileY;
    Tile* lastTile;
};


//-------------------------------------------------------------------


// all the rows of a level
class LevelBuffer : public Buffer {
public:
    LevelBuffer(int l);
    virtual ~LevelBuffer();
    
    virtual Tile* get(int l, int x, int y);
    virtual Tile* add(int l, int x, int y);
    virtual void dump(int indent);

private:
    // all the rows of (a level)
    std::map<int, RowsBuffer*> map;    // row -> (row buffer)
};


//-------------------------------------------------------------------


// all the levels
class CloudBuffer : public Buffer
{
public:
    CloudBuffer();
    virtual ~CloudBuffer();
    
    virtual Tile* get(int l, int x, int y);
    virtual Tile* add(int l, int x, int y);
    virtual void dump(int indent);

private:
    // all the levels of the cloud
    std::map<int, LevelBuffer*> map;    // level -> (level buffer)
};

#endif
