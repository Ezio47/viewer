library point_cloud;

import 'dart:core';
import 'package:three/three.dart';
import 'dart:math' as Math;


// given a set of dimensions, as returned by FileGenerator, this class represents
// the cloud itself

class PointCloud
{
  Map<String, GeometryAttribute> map;
  int numPoints;
  double minx, maxx, miny, maxy, minz, maxz;

  PointCloud(Map<String, GeometryAttribute> mymap)
  {
    map = mymap;

    _checkValid();

    if (!map.containsKey("positions"))
    {
      combineXYZ();
    }

    numPoints = map["positions"].numItems.toInt() ~/ 3;

    if (! mymap.containsKey("colors"))
    {
      _addColorArray();
    }

    computeBounds();
  }


  void colorize()
  {
    double zLen = maxz - minz;

    var positions = map["positions"].array;
    var colors = map["colors"].array;
    var numItems = map["colors"].numItems;

    for (int i=0; i<numPoints*3; i+=3)
    {
      double z = positions[i+2];
      double c = (z - minz) / zLen;

      // clip, due to FP math
      assert(c >= -0.1 && c <= 1.1);
      if (c<0.0) c = 0.0;
      if (c>1.0) c = 1.0;

      // a silly ramp
      if (c < 0.3333)
      {
        colors[i] = c * 3.0;
        colors[i+1] = 0.0;
        colors[i+2] = 0.0;
      }
      else if (c < 0.6666)
      {
        colors[i] = 0.0;
        colors[i+1] = (c - 0.3333) * 3.0;
        colors[i+2] = 0.0;
      }
      else
      {
        colors[i] = 0.0;
        colors[i+1] = 0.0;
        colors[i+2] = (c - 0.6666) * 3.0;
      }
    }
  }


  void _addColorArray()
  {
    var colors = new GeometryAttribute.float32(numPoints * 3, 3);
    for (int i=0; i<numPoints*3; i+=3)
    {
      colors.array[i] = 1.0;
      colors.array[i+1] = 1.0;
      colors.array[i+2] = 1.0;
    }

    map["colors"] = colors;
  }


  void computeBounds()
  {
    minx = map["positions"].array[0];
    maxx = map["positions"].array[0];
    miny = map["positions"].array[1];
    maxy = map["positions"].array[1];
    minz = map["positions"].array[2];
    maxz = map["positions"].array[2];

    for (int i=3; i<numPoints; i+=3)
    {
      minx = Math.min(minx, map["positions"].array[i]);
      maxx = Math.max(maxx, map["positions"].array[i]);
      miny = Math.min(miny, map["positions"].array[i+1]);
      maxy = Math.max(maxy, map["positions"].array[i+1]);
      minz = Math.min(minz, map["positions"].array[i+2]);
      maxz = Math.max(maxz, map["positions"].array[i+2]);
    }
  }

  void combineXYZ()
  {
    num count = map["x"].numItems;

    var positions = new GeometryAttribute.float32(count * 3, 3);
    map["positions"] = positions;

    for (int i=0, j=0; i<count; i++, j+=3)
    {
      positions.array[j] = map["x"].array[i];
      positions.array[j+1] = map["y"].array[i];
      positions.array[j+2] = map["z"].array[i];
    }

    map.remove("x");
    map.remove("y");
    map.remove("z");
  }


  void _checkValid()
  {
    bool xyz = map.containsKey("x") && map.containsKey("y") && map.containsKey("z");
    bool positions = map.containsKey("positions");
    assert(xyz || positions);
    assert(!(xyz && positions));

    num count = map[map.keys.first].numItems;
    for (var k in map.keys)
    {
      assert(map[k].numItems == count);
    }
  }
}
