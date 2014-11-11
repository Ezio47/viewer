library point_cloud;

import 'dart:core';
import 'package:three/three.dart';
//import 'dart:math' as Math;


// given a set of dimensions, as returned by FileGenerator, this class represents
// the cloud itself

class PointCloud
{
  Map<String, GeometryAttribute> map;
  
  PointCloud(Map<String, GeometryAttribute> mymap)
  {
    map = mymap;
   
    _checkValid();

    if (!map.containsKey("positions"))
    {
      combineXYZ();
    }
    
    assert(mymap.containsKey("colors"));
  }
  
  void combineXYZ()
  {
    num count = map["x"].numItems;
    var positions = new GeometryAttribute.float32(count * 3, 3);
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
