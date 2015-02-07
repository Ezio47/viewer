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

#include "Rectangle.hpp"


class Point
{
public:
    Point(double x_, double y_, double z_) :
        x(x_),
        y(y_),
        z(z_)
    { }
    
    Point(const Point& r) :
        x(r.x),
        y(r.y),
        z(r.z)
    { }
    
    double x;
    double y;
    double z;
    
    Point& operator=(const Point& r)
    {
      x = r.x;
      y = r.y;
      z = r.z;
      return *this;
    }
};


class Tile
{
public:    
    Tile(int level, int tx, int ty, Rectangle r, int maxLevel);
    ~Tile();
    
    std::vector<Point>& vec() { return m_points; }
    
    void add(double lon, double lat, double height);
    
    void dump(int indent) const;
    
    void stats(int* numPointsPerLevel, int* numTilesPerLevel) const;
    
    int m_level, m_tileX, m_tileY;
    std::vector<Point> m_points;
    
    Tile* parent;
    Tile** m_children;
    Rectangle rect;
    int m_maxLevel;
};

#endif
