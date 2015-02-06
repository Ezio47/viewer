// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

#include "Buffer.hpp"


Buffer::Buffer(int l, int x, int y) :
  level(l), tileX(x), tileY(y) {
    return;
}

Buffer::~Buffer()
{
}


/////////////////////////////////////////////////////////////////


RowsBuffer::RowsBuffer(int l, int x, int y) : Buffer(l, x, y)
{
    assert(l != -1);
    assert(x != -1);
    assert(y == -1);
    return;
}

RowsBuffer::~RowsBuffer()
{
}


Tile* RowsBuffer::get(int l, int x, int y)
{
    assert(l == level);
    assert(x == tileX);
    assert(-1 == tileY);

    Tile* tile = map[y];
    if (!tile) return NULL;

    return tile;
}


Tile* RowsBuffer::add(int l, int x, int y)
{
    assert(l == level);
    assert(x == tileX);
    assert(-1 == tileY);

    Tile* tile = get(l, x, y);
    if (!tile) {
        map.insert( std::pair<int,Tile*>(x, new Tile(l, x, y)) );
        tile = map[y];
    }
    return tile;
}


/////////////////////////////////////////////////////////////////


LevelBuffer::LevelBuffer(int l, int x, int y) : Buffer(l, x, y)
{
    assert(l != -1);
    assert(x == -1);
    assert(y == -1);
}


LevelBuffer::~LevelBuffer()
{
}


Tile* LevelBuffer::get(int l, int x, int y)
{
    assert(l == level);
    assert(-1 == tileX);
    assert(-1 == tileY);

    RowsBuffer* rows = map[x];
    if (!rows) return NULL;

    return rows->get(l, x, y);
}


Tile* LevelBuffer::add(int l, int x, int y)
{
    assert(l == level);
    assert(-1 == tileX);
    assert(-1 == tileY);

    RowsBuffer* rows = map[x];
    if (!rows) {
        map.insert( std::pair<int, RowsBuffer*>(x, new RowsBuffer(l, x, -1)) );
        rows = map[x];
    }
    return rows->add(l, x, y);
}


//////////////////////////////////////////////////////////////////


CloudBuffer::CloudBuffer(int l, int x, int y) : Buffer(l, x, y)
{
    assert(l == -1);
    assert(x == -1);
    assert(y == -1);
}


CloudBuffer::~CloudBuffer()
{
}


Tile* CloudBuffer::get(int l, int x, int y)
{
    assert(-1 == level);
    assert(-1 == tileX);
    assert(-1 == tileY);

    LevelBuffer* level = map[l];
    if (!level) return NULL;

    return level->get(l, x, y);
}


Tile* CloudBuffer::add(int l, int x, int y)
{
    assert(-1 == level);
    assert(-1 == tileX);
    assert(-1 == tileY);

    LevelBuffer* level = map[l];
    if (!level) {
        map.insert( std::pair<int,LevelBuffer*>(x, new LevelBuffer(l, -1, -1)) );
        level = map[l];
    }
    return level->add(l, x, y);
}
