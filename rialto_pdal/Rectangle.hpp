// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

#ifndef RECTANGLE_HPP
#define RECTANGLE_HPP

#include <pdal/PipelineManager.hpp>
#include <boost/math/constants/constants.hpp>


enum Quad {
    QuadSW=0, QuadNW=1, QuadSE=2, QuadNE=3,
};


class Rectangle {
public:
    double north, south, east, west;
  
    Rectangle() :
      north(0.0),
      south(0.0),
      east(0.0),
      west(0.0)
    {
      return;
    }

    Rectangle(double w, double s, double e, double n) :
      north(n),
      south(s),
      east(e),
      west(w)
    {
      return;
    }

    Rectangle(const Rectangle& r) :
      north(r.north),
      south(r.south),
      east(r.east),
      west(r.west)
    {
      return;
    }

    Rectangle& operator=(const Rectangle& r)
    {
      north = r.north;
      south = r.south;
      east = r.east;
      west = r.west;
      return *this;
    }

    Quad getQuadrantOf(double lon, double lat) {
        double midx = (west + east)/2.0;
        double midy = (south + north)/2.0;
        
        // NW=1  NE=3
        // SW=0  SE=2
        int lowX = (lon <= midx);
        int lowY = (lat <= midy);
        
        if (lowX && lowY) return QuadSW;
        if (lowX && !lowY) return QuadNW;
        if (!lowX && lowY) return QuadSE;
        if (!lowX && !lowY) return QuadNE;
         assert(0);
    }
    
    Rectangle getQuadrantRect(Quad q) {
        double midx = (west + east)/2.0;
        double midy = (south + north)/2.0;

        // w s e n
        if (q == QuadSW) return Rectangle(west, south, midx, midy);
        if (q == QuadNW) return Rectangle(west, midy, midx, north);
        if (q == QuadSE) return Rectangle(midx, south, east, midy);
        if (q == QuadNE) return Rectangle(midx, midy, east, north);
        assert(false);
    }
            
    bool contains(double lon, double lat) const
    {
        return (lon >= west) && (lon <= east) &&
               (lat >= south) && (lat <= north);
    }
};

#endif
