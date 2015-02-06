// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

#ifndef TILINGSCHEME_HPP
#define TILINGSCHEME_HPP

// this code based on
// https://github.com/AnalyticalGraphicsInc/cesium/blob/1.6/Source/Core/GeographicTilingScheme.js

#include <pdal/PipelineManager.hpp>
#include <boost/math/constants/constants.hpp>


#include "Rectangle.hpp"

class TilingScheme {
public:
  TilingScheme(Rectangle& rectangle,
               int numberOfLevelZeroTilesX,   // 2
               int numberOfLevelZeroTilesY) ; // 1

  const Rectangle& getRectangle() const;

  int getNumberOfXTilesAtLevel(int level) const;
  int getNumberOfYTilesAtLevel(int level) const;

  Rectangle rectangleToNativeRectangle(const Rectangle& rectangle) const;

  Rectangle tileXYToNativeRectangle(int x, int y, int level) const;
  Rectangle tileXYToRectangle(int x, int y, int level) const;

  bool positionToTileXY(double xPosition, double yPosition,
                        int level,
                        int& xResult, int& yResult) const;

  static double toDegrees(double radians);
  static double toRadians(double degrees);

private:
  Rectangle _rectangle;
  int _numberOfLevelZeroTilesX;
  int _numberOfLevelZeroTilesY;
};

#endif
