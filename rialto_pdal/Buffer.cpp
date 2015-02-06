// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

#include "Buffer.hpp"


Buffer::Buffer(int l, int x, int y) :
    level(l), tileX(x), tileY(y)
{
}

Buffer::~Buffer()
{
}


/////////////////////////////////////////////////////////////////


RowsBuffer::RowsBuffer(int l, int y) : Buffer(l, -1, y)
{
    assert(l != -1);
    assert(y != -1);
    printf("created rb (%d,%d,%d)\n", level, tileX, tileY);
    return;
}

RowsBuffer::~RowsBuffer()
{
}


Tile* RowsBuffer::get(int l, int x, int y)
{
    assert(l == level);
    assert(-1 == tileX);
    assert(y == tileY);

    Tile* tile = map[x];
    if (!tile) return NULL;

    return tile;
}


Tile* RowsBuffer::add(int l, int x, int y)
{
    assert(l == level);
    assert(-1 == tileX);
    assert(y == tileY);

    Tile* tile = NULL;
    auto search = map.find(x);
    if (search != map.end()) {
        tile = search->second;
    } else {
        tile = new Tile(l, x, y); 
        map.emplace(x, tile);
    }
    return tile;
}


void RowsBuffer::dump(int indent)
{
    for (int i=0; i<indent; i++) printf(" ");
    printf("rb(%d,%d,%d)\n", level, tileX, tileY);

    auto it = map.begin();
    while (it != map.end()) {
        Tile* v = it->second;
        v->dump(indent+4);
        ++it;
    }
}


/////////////////////////////////////////////////////////////////


LevelBuffer::LevelBuffer(int l) : Buffer(l, -1, -1)
{
    assert(l != -1);
    printf("created lb (%d,%d,%d)\n", level, tileX, tileY);
}


LevelBuffer::~LevelBuffer()
{
}


Tile* LevelBuffer::get(int l, int x, int y)
{
    assert(l == level);
    assert(-1 == tileX);
    assert(-1 == tileY);

    RowsBuffer* rows = map[y];
    if (!rows) return NULL;

    return rows->get(l, x, y);
}


Tile* LevelBuffer::add(int l, int x, int y)
{
    assert(l == level);
    assert(-1 == tileX);
    assert(-1 == tileY);

    RowsBuffer* rows = NULL;
    auto search = map.find(y);
    if (search != map.end()) {
        rows = search->second;
    } else {
        rows = new RowsBuffer(l, y); 
        map.emplace(y, rows);
    }
    return rows->add(l, x, y);
}


void LevelBuffer::dump(int indent)
{
    for (int i=0; i<indent; i++) printf(" ");
    printf("lb (%d,%d,%d)\n", level, tileX, tileY);

    auto it = map.begin();
    while (it != map.end()) {
        RowsBuffer *v = it->second;
        v->dump(indent+4);
        ++it;
    }
}


//////////////////////////////////////////////////////////////////


CloudBuffer::CloudBuffer() : Buffer(-1, -1, -1)
{
    printf("created cb (%d,%d,%d)\n", level, tileX, tileY);
}


CloudBuffer::~CloudBuffer()
{
}


Tile* CloudBuffer::get(int l, int x, int y)
{
    assert(-1 == level);
    assert(-1 == tileX);
    assert(-1 == tileY);

    LevelBuffer* levelBuffer = map[l];
    if (!levelBuffer) return NULL;

    return levelBuffer->get(l, x, y);
}


Tile* CloudBuffer::add(int l, int x, int y)
{
    assert(-1 == level);
    assert(-1 == tileX);
    assert(-1 == tileY);

    LevelBuffer* levels = NULL;
    auto search = map.find(l);
    if (search != map.end()) {
        levels = search->second;
     } else {
        levels = new LevelBuffer(l); 
        map.emplace(l, levels);
    }
    return levels->add(l, x, y);
}


void CloudBuffer::dump(int indent)
{
    for (int i=0; i<indent; i++) printf(" ");
    printf("cb (%d,%d,%d)\n", level, tileX, tileY);
     
    auto it = map.begin();
    auto e = map.end();
    while (it != e) {
        LevelBuffer *v = it->second;
        v->dump(indent+4);
        ++it;
    }
}
