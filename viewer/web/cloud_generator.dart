library cloud_generator;

import 'dart:core';
import 'package:three/three.dart';
import 'dart:math' as Math;


// this class pretends to represent a pointcloud file: all it does is
// return a set of points, like a file would
//
// each statuc function returns a structure:
// {
//   "dim1" : GeometryAttribute.float32
//   "dim2" : GeometryAttribute.float32
//   ...
// }
//
// geamattrib has numitems and itemsize
//
// we assume each file wil return at least dims for x, y, and z

class CloudGenerator
{
  static Map<String, GeometryAttribute> generate(String name)
  {
    switch (name)
    {
      case "1":
        return makeNewCube(5000);
      case "2":
        return makeOldCube();
      case "3":
        return makeRandom();
      case "4":
        return makeLine();
      default:
        return makeNewCube(5000);
    }
  }
  
  
  static Map<String, GeometryAttribute> makeNewCube(num particles)
  {
    Map<String, GeometryAttribute> map = new Map();
    
    var positions = new GeometryAttribute.float32(particles * 3, 3);
    var colors     = new GeometryAttribute.float32(particles * 3, 3);
    assert(colors.itemSize == 3);
    assert(colors.numItems == particles*3);
    
    map["positions"] = positions;
    map["colors"] = colors;
    
    var rnd = new Math.Random();
    
    var color = new Color();
  
    var n = 1000.0, n2 = n / 2.0; // particles spread in the cube
  
    for ( var i = 0; i < positions.array.length; i += 3 ) {
    
      // positions
      var x = rnd.nextDouble() * n - n2;   // -500..+500
      var y = rnd.nextDouble() * n - n2;
      var z = rnd.nextDouble() * n - n2;
      assert(x>=-500.0 && y>=-500.0 && z>=-500.0);
      assert(x<=500.0 && y<=500.0 && z<=500.0);
      //print("$x $y $z");
      
      positions.array[ i     ] = x;
      positions.array[ i + 1 ] = y;
      positions.array[ i + 2 ] = z;
    
      // colors
      var vx = ( x / n ) + 0.5;
      var vy = ( y / n ) + 0.5;
      var vz = ( z / n ) + 0.5;
    
      color.setRGB( vx, vy, vz );
    
      //colors.array[ i ]     = color.r;
      //colors.array[ i + 1 ] = color.g;
      //colors.array[ i + 2 ] = color.b;
      
      if (x < 0.0 && y < 0.0 && z < 0.0)
      {
        // red at -5,-5,-5
        colors.array[i] = 1.0;
        colors.array[i+1] = 0.0;
        colors.array[i+2] = 0.0;
        //print("$x $y $z");
      }
      else if (x > 0.0 && y > 0.0 && z> 0.0)
      {
        // blue at +5,+5,+5
        colors.array[i] = 0.0;
        colors.array[i+1] = 0.0;
        colors.array[i+2] = 1.0;
      }
      else
      {
        colors.array[i] = 0.0;
        colors.array[i+1] = 0.0;
        colors.array[i+2] = 0.0;
      }
    }
  
    return map;
  }


  static Map<String, GeometryAttribute> makeOldCube()
  {
    Map<String, GeometryAttribute> map = new Map();
    
    var positions = new GeometryAttribute.float32(8 * 3, 3);
    map["positions"] = positions;
    
    double xmin = 0.0;
    double xmax = 5.0;
    double ymin = 0.0;
    double ymax = 10.0;
    double zmin = 0.0;
    double zmax = 15.0;
    
    // x = red
    // y = green
    // z = blue
    
    List points = [];
      
    // X
    points.addAll([xmin, ymin, zmin]);
    points.addAll([xmax, ymin, zmin]);
    points.addAll([xmin, ymax, zmin]);
    points.addAll([xmax, ymax, zmin]);
    points.addAll([xmin, ymin, zmax]);
    points.addAll([xmax, ymin, zmax]);
    points.addAll([xmin, ymax, zmax]);
    points.addAll([xmax, ymax, zmax]);
    
    // Y
    points.addAll([xmin, ymin, zmin]);
    points.addAll([xmin, ymax, zmin]);
    points.addAll([xmax, ymin, zmin]);
    points.addAll([xmax, ymax, zmin]);
    points.addAll([xmin, ymin, zmax]);
    points.addAll([xmin, ymax, zmax]);
    points.addAll([xmax, ymin, zmax]);
    points.addAll([xmax, ymax, zmax]);
    
    // Z
    points.addAll([xmin, ymin, zmin]);
    points.addAll([xmin, ymin, zmax]);
    points.addAll([xmax, ymin, zmin]);
    points.addAll([xmax, ymin, zmax]);
    points.addAll([xmin, ymax, zmin]);
    points.addAll([xmin, ymax, zmax]);
    points.addAll([xmax, ymax, zmin]);
    points.addAll([xmax, ymax, zmax]);
    
    var numPoints = 8*3;
    for (int i=0; i<numPoints*3; i+=3)
    {
      positions.array[i] = points[i];
      positions.array[i+1] = points[i+1];
      positions.array[i+2] = points[i+2];
    }
    
    return map;
  }
  

  static Map<String, GeometryAttribute> makeRandom()
  {
    Map<String, GeometryAttribute> map = new Map();
    
    var numPoints = 5000;
    
    var positions = new GeometryAttribute.float32(numPoints * 3, 3);
    map["positions"] = positions;

    var xdim = 5;
    var ydim = 20;
    var zdim = 10;
     
    var random = new Math.Random();
     
    for (var i=0; i<numPoints*3; i+=3)
    {
      var x = random.nextDouble() * xdim;
      var y = random.nextDouble() * ydim;
      var z = random.nextDouble() * zdim;
      positions.array[i] = x;
      positions.array[i+1] = y;
      positions.array[i+2] = z;
    }
    
    return map;
  }


  static Map<String, GeometryAttribute> makeLine()
  {
    Map<String, GeometryAttribute> map = new Map();
    
    var K = 1000;
    var siz = 20 * K;
    
    var positions = new GeometryAttribute.float32(siz * 3, 3);
    map["positions"] = positions;
       
    for (var i=0; i<siz*3; i+=3)
    {
      var pt = (i / siz) * 10.0;
      positions.array[i] = pt;
      positions.array[i+1] = pt;
      positions.array[i+2] = pt;
    }  
    
    return map;
  }
}
