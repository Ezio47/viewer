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

#include "Tile.hpp"


class TileWriter
{
public:
    TileWriter(int level);
    ~TileWriter();

    void seed(const pdal::PointBufferSet& pointBuffers);
    
private:
    void seed(const pdal::PointBufferPtr& buf, int& pointNumber);
    
    Tile* m_root0;
    Tile* m_root1;
    
    int m_maxLevel;
    
    TileWriter& operator=(const TileWriter&); // not implemented
    TileWriter(const TileWriter&); // not implemented
};

#endif
