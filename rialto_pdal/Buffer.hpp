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

protected:
    int level;
    int tileX;
    int tileY;
};


//-------------------------------------------------------------------


// all the cols of (a row of a level)
class RowsBuffer : public Buffer
{
public:
    RowsBuffer(int l, int x, int y);
    virtual ~RowsBuffer();
    
    Tile* get(int l, int x, int y);
    Tile* add(int l, int x, int y);

private:
    // all the cols of (a row of a level)
    std::map<int, Tile*> map;   // col -> (tile buffer)
};


//-------------------------------------------------------------------


// all the rows of a level
class LevelBuffer : public Buffer {
public:
    LevelBuffer(int l, int x, int y);
    virtual ~LevelBuffer();
    
    Tile* get(int l, int x, int y);
    Tile* add(int l, int x, int y);

private:
    // all the rows of (a level)
    std::map<int, RowsBuffer*> map;    // row -> (row buffer)
};


//-------------------------------------------------------------------


// all the levels
class CloudBuffer : public Buffer
{
public:
    CloudBuffer(int l, int x, int y);
    virtual ~CloudBuffer();
    
    Tile* get(int l, int x, int y);
    Tile* add(int l, int x, int y);

private:
    // all the levels of the cloud
    std::map<int, LevelBuffer*> map;    // level -> (level buffer)
};

#endif
