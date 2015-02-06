// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

#ifndef RECTANGLE_HPP
#define RECTANGLE_HPP

#include <pdal/PipelineManager.hpp>
#include <boost/math/constants/constants.hpp>


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

    Rectangle(double n, double s, double e, double w) :
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

    double width() const {
      static const double PI = boost::math::constants::pi<double>();
      double e = east;
        if (east < west) {
            e += 2.0 * PI;
        }
        return e - west;
    }

    double height() const {
        return north - south;
    }

    static bool equalsEpsilon(double left, double right, double relativeEpsilon)
    {
        double absoluteEpsilon = relativeEpsilon;

        double absDiff = abs(left - right);

        return absDiff <= absoluteEpsilon || absDiff <= relativeEpsilon * fmax(abs(left), abs(right));
    }

    bool contains(double lon, double lat) const
    {
        static const double PI = boost::math::constants::pi<double>();
        static const double EPS14 = 0.00000000000001;

        double e = east;
        if (east < west) {
            e += PI * 2.0;
            if (lon < 0.0) {
                lon += 2.0 * PI;
            }
        }

        return (lon > west || equalsEpsilon(lon, west, EPS14)) &&
               (lon < e || equalsEpsilon(lon, e, EPS14)) &&
               lat >= south &&
               lat <= north;
    }
};

#endif
