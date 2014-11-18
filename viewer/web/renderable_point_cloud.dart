library renderable_point_cloud;

import 'dart:core';
import 'package:three/three.dart';
import 'dart:math' as Math;
import 'package:vector_math/vector_math.dart';
import 'dart:typed_data';

// given a set of dimensions, as returned by FileGenerator, this class represents
// the cloud itself

class RenderablePointCloud
{
  Map<String, GeometryAttribute> dims = new Map<String, GeometryAttribute>();
  int numPoints;
  Vector3 low, high;

  RenderablePointCloud(Map<String, Float32List> mydims)
  {
     setDims(mydims);

     _checkValid();

    if (!dims.containsKey("positions"))
    {
      combineXYZ();
    }

    numPoints = dims["positions"].numItems.toInt() ~/ 3;

    if (! dims.containsKey("colors"))
    {
      _addColorArray();
    }

    computeBounds();
  }


  void setDims(Map<String, Float32List> mydims)
  {
      int numPoints = mydims["positions.x"].length;

      var positions = new GeometryAttribute.float32(numPoints * 3, 3);
      for (int i=0; i<numPoints; i++) {
          positions.array[i*3+0] = mydims["positions.x"][i];
          positions.array[i*3+1] = mydims["positions.y"][i];
          positions.array[i*3+2] = mydims["positions.z"][i];
      }
      dims["positions"] = positions;

      if (mydims.containsKey("colors.x")) {
          var colors = new GeometryAttribute.float32(numPoints * 3, 3);
          for (int i=0; i<numPoints; i++) {
              colors.array[i*3+0] = mydims["colors.x"][i];
              colors.array[i*3+1] = mydims["colors.y"][i];
              colors.array[i*3+2] = mydims["colors.z"][i];
          }
          dims["colors"] = colors;
      }
  }

  void colorize()
  {
    double zLen = high.z - low.z;

    var positions = dims["positions"].array;
    var colors = dims["colors"].array;
    var numItems = dims["colors"].numItems;

    for (int i=0; i<numPoints*3; i+=3)
    {
      double z = positions[i+2];
      double c = (z - low.z) / zLen;

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

    dims["colors"] = colors;
  }


  void computeBounds()
  {
    var minx = dims["positions"].array[0];
    var maxx = dims["positions"].array[0];
    var miny = dims["positions"].array[1];
    var maxy = dims["positions"].array[1];
    var minz = dims["positions"].array[2];
    var maxz = dims["positions"].array[2];

    for (int i=3; i<numPoints*3; i+=3)
    {
      var x = dims["positions"].array[i];
      var y = dims["positions"].array[i+1];
      var z = dims["positions"].array[i+2];

      minx = Math.min(minx, x);
      maxx = Math.max(maxx, x);
      miny = Math.min(miny, y);
      maxy = Math.max(maxy, y);
      minz = Math.min(minz, z);
      maxz = Math.max(maxz, z);
    }

    low = new Vector3(minx, miny, minz);
    high = new Vector3(maxx, maxy, maxz);
  }

  void combineXYZ()
  {
    num count = dims["x"].numItems;

    var positions = new GeometryAttribute.float32(count * 3, 3);
    dims["positions"] = positions;

    for (int i=0, j=0; i<count; i++, j+=3)
    {
      positions.array[j] = dims["x"].array[i];
      positions.array[j+1] = dims["y"].array[i];
      positions.array[j+2] = dims["z"].array[i];
    }

    dims.remove("x");
    dims.remove("y");
    dims.remove("z");
  }


  void _checkValid()
  {
    bool xyz = dims.containsKey("x") && dims.containsKey("y") && dims.containsKey("z");
    bool positions = dims.containsKey("positions");
    assert(xyz || positions);
    assert(!(xyz && positions));

    num count = dims[dims.keys.first].numItems;
    for (var k in dims.keys)
    {
      assert(dims[k].numItems == count);
    }
  }
}
