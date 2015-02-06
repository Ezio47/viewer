// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

#ifndef TILEWRITER_HPP
#define TILEWRITER_HPP

#include <pdal/Writer.hpp>
#include <pdal/FileUtils.hpp>
#include <pdal/StageFactory.hpp>

#include <memory>
#include <vector>
#include <string>

#include <zlib.h>

#include "TilingScheme.hpp"
#include "Tile.hpp"
#include "Buffer.hpp"


class TileWriter
{
public:
    TileWriter(int level);
    ~TileWriter();

    void build(const pdal::PointBufferSet& pointBuffers);
    
private:
    void seed(const pdal::PointBufferSet& pointBuffers);
    void seed(const pdal::PointBufferPtr& buf);
    void generateLevel(int level, int tx, int ty, Tile& srcTile);
    void generateLevel(int parentLevel);

    TilingScheme* m_scheme;
    int m_maxLevel;
    CloudBuffer* m_storage;
    
    TileWriter& operator=(const TileWriter&); // not implemented
    TileWriter(const TileWriter&); // not implemented
};

#endif
