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

#include "PdalBridge.hpp"
#include "Tile.hpp"


class TileWriter
{
public:
    TileWriter(const PdalBridge& pdal, int maxLevel);
    ~TileWriter();

    void build();
    void write(const char* dir) const;
    
    void dump() const;
    
private:
    void build(const pdal::PointBufferPtr& buf, int& pointNumber);
    char* getPointData(const pdal::PointBufferPtr& buf, int& pointNumber);
    void writeHeader(const char* dir) const;
    
    const PdalBridge& m_pdal;
    int m_bytesPerPoint;
    
    int m_numTilesX;
    int m_numTilesY;
    Rectangle m_rectangle;
    Tile* m_root0;
    Tile* m_root1;
    
    int m_maxLevel;
    
    TileWriter& operator=(const TileWriter&); // not implemented
    TileWriter(const TileWriter&); // not implemented
};

#endif
