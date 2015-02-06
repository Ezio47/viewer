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


RowsBuffer::RowsBuffer(int l, int y) : Buffer(l, -1, y),
    lastLevel(-1),
    lastTileX(-1),
    lastTileY(-1)
{
    assert(l != -1);
    assert(y != -1);
    printf("created rb (%d,%d)\n", level, tileY);
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

    if (lastLevel == l && lastTileX == x && lastTileY == y) {
    printf("hit");
        return lastTile;
    }

    auto search = map.find(x);
    if (search == map.end()) {
        return NULL;
    }
    Tile* v = search->second;
    
    lastLevel = l;
    lastTileX = x;
    lastTileY = y;
    lastTile = v;
    
    return v;
}


Tile* RowsBuffer::add(int l, int x, int y)
{
    assert(l == level);
    assert(-1 == tileX);
    assert(y == tileY);

    if (lastLevel == l && lastTileX == x && lastTileY == y) {
    printf("hit");
        return lastTile;
    }
    
    Tile* tile = NULL;
    auto search = map.find(x);
    if (search != map.end()) {
        tile = search->second;
    } else {
        tile = new Tile(l, x, y); 
        map.emplace(x, tile);
    }
    
    lastLevel = l;
    lastTileX = x;
    lastTileY = y;
    lastTile = tile;
    
    return tile;
}


void RowsBuffer::dump(int indent)
{
    for (int i=0; i<indent; i++) printf(" ");
    printf("> rb (%d,%d)\n", level, tileY);

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
    printf("created lb (%d)\n", level);
}


LevelBuffer::~LevelBuffer()
{
}


Tile* LevelBuffer::get(int l, int x, int y)
{
    assert(l == level);
    assert(-1 == tileX);
    assert(-1 == tileY);

    auto search = map.find(y);
    if (search == map.end()) {
        return NULL;
    }
    RowsBuffer* v = search->second;
    return v->get(l, x, y);
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
    printf("> lb (%d)\n", level);

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
    printf("created cb ()\n");
}


CloudBuffer::~CloudBuffer()
{
}


Tile* CloudBuffer::get(int l, int x, int y)
{
    assert(-1 == level);
    assert(-1 == tileX);
    assert(-1 == tileY);

    auto search = map.find(l);
    if (search == map.end()) {
        return NULL;
    }
    LevelBuffer* levels = search->second;
    return levels->get(l, x, y);
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
    printf("> cb ()\n");
     
    auto it = map.begin();
    auto e = map.end();
    while (it != e) {
        LevelBuffer *v = it->second;
        v->dump(indent+4);
        ++it;
    }
}
