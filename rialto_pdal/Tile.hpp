// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

#ifndef TILE_HPP
#define TILE_HPP

#include <pdal/Writer.hpp>
#include <pdal/FileUtils.hpp>
#include <pdal/StageFactory.hpp>

#include <memory>
#include <vector>
#include <string>

#include <zlib.h>

#include "PdalBridge.hpp"
#include "Rectangle.hpp"



class Tile
{
public:    
    Tile(boost::uint32_t level, boost::uint32_t tx, boost::uint32_t ty, Rectangle r, boost::uint32_t maxLevel, const PdalBridge& pdal);
    ~Tile();
    
    std::vector<char*>& points() { return m_points; }
    boost::uint64_t numPoints() const { return m_points.size(); }
    
    void add(boost::uint64_t pointNumber, char* data, double lon, double lat);
    
    void dump(int indent) const;
    
    void collectStats(boost::uint32_t* numTilesPerLevel, boost::uint64_t* numPointsPerLevel) const;
    
    void write(const char* dir) const;
    void writeData(FILE*) const;
    
 private:
    boost::uint32_t m_level, m_tileX, m_tileY;
    std::vector<char*> m_points;
    
    Tile** m_children;
    Rectangle rect;
    boost::uint32_t m_maxLevel;
    boost::uint64_t m_skip;
    const PdalBridge& m_pdal;
};

#endif
