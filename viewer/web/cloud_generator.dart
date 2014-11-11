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
// we assume each file will return at least dims for x, y, and z (or 'positions')

class CloudGenerator
{
  static Map<String, GeometryAttribute> generate(String name)
  {
    switch (name)
    {
      case "1":
        return makeNewCube();
      case "2":
        return makeOldCube();
      case "3":
        return makeRandom();
      case "4":
        return makeLine();
      case "5":
        return makeTerrain();
      default:
        return makeNewCube();
    }
  }


  static Map<String, GeometryAttribute> makeNewCube()
  {
    num particles = 50000;

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

    var numPoints = 24;

    var xx = new GeometryAttribute.float32(numPoints, 3);
    var yy = new GeometryAttribute.float32(numPoints, 3);
    var zz = new GeometryAttribute.float32(numPoints, 3);
    map["x"] = xx;
    map["y"] = yy;
    map["z"] = zz;

    double xmin = 0.0;
    double xmax = 500.0;
    double ymin = 0.0;
    double ymax = 1000.0;
    double zmin = 0.0;
    double zmax = 1500.0;

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

    for (int i=0; i<numPoints; i++)
    {
      xx.array[i] = points[i*3];
      yy.array[i] = points[i*3+1];
      zz.array[i] = points[i*3+2];
    }

    return map;
  }


  static Map<String, GeometryAttribute> makeRandom()
  {
    Map<String, GeometryAttribute> map = new Map();

    var numPoints = 50000;

    var positions = new GeometryAttribute.float32(numPoints * 3, 3);
    map["positions"] = positions;

    var xdim = 500;
    var ydim = 2000;
    var zdim = 1000;

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

    var numPoints = 2000;

    var positions = new GeometryAttribute.float32(numPoints * 3, 3);
    map["positions"] = positions;

    for (var i=0; i<numPoints*3; i+=3)
    {
      double pt = i.toDouble() / 10.0;
      positions.array[i] = pt;
      positions.array[i+1] = pt;
      positions.array[i+2] = pt;
    }

    return map;
  }


  static Map<String, GeometryAttribute> makeTerrain()
  {
    Terrain terrain = new Terrain();

    Map<String, GeometryAttribute> map = new Map();
    map["positions"] = terrain.values;

    return map;
  }
}


// http://www.bluh.org/code-the-diamond-square-algorithm/
class Terrain
{
  int width, height;
  var values;
  var rnd = new Math.Random();

  Terrain()
  {
    width = 512;
    height = 512;
    values = new GeometryAttribute.float32(width*height * 1, 1);

    int featuresize = 32;

    for( int y = 0; y < height; y += featuresize)
    {
      for (int x = 0; x < width; x += featuresize)
      {
        setSample(x, y, frand());

        //if (x>100 && x<200 && y>100 && y<200)
        //{
         // setSample(x,y,10.0);
        //}
      }
    }

    int samplesize = featuresize;

    double scale = 1.0;

    while (samplesize > 1)
    {
      doDiamondSquare(samplesize, scale);

      samplesize = samplesize ~/ 2;
      scale = scale / 2.0;
    }

    var t = new GeometryAttribute.float32(width*height * 3, 3);
    int i=0;
    for (int w=0; w<width; w++)
    {
      for (int h=0; h<height; h++)
      {
        double x = w.toDouble();
        double y = h.toDouble();
        double z = getSample(w,h);

        // jiggle the (x,y) points, to prevent visual artifacts
        x += (rnd.nextDouble() - 0.5);
        y += (rnd.nextDouble() - 0.5);

        // for better viewing, center the data at zero and spread it out more
        x = (x - width/2) * 5.0;
        y = (y - height/2) * 5.0;

        // for better viewing, exaggerate Z
        z = z * 200.0;

        t.array[i++] = x;
        t.array[i++] = y;
        t.array[i++] = z;
      }
    }

    values = t;
  }

  double getSample(int x, int y)
  {
    x = x & (width - 1);
    y = y & (height - 1);
    return values.array[x + y * width];
  }

  void setSample(int x, int y, double value)
  {
    x = x & (width - 1);
    y = y & (height - 1);
    values.array[x + y * width] = value;
  }

  void sampleSquare(int x, int y, int size, double value)
  {
    int hs = size ~/ 2;

    // a     b
    //
    //    x
    //
    // c     d

    double a = getSample(x - hs, y - hs);
    double b = getSample(x + hs, y - hs);
    double c = getSample(x - hs, y + hs);
    double d = getSample(x + hs, y + hs);

    setSample(x, y, ((a + b + c + d) / 4.0) + value);
   }

  void sampleDiamond(int x, int y, int size, double value)
  {
    int hs = size ~/ 2;

    //   c
    //
    //a  x  b
    //
    //   d

    double a = getSample(x - hs, y);
    double b = getSample(x + hs, y);
    double c = getSample(x, y - hs);
    double d = getSample(x, y + hs);

    setSample(x, y, ((a + b + c + d) / 4.0) + value);
  }

  double frand()
  {
    // return in range [-1..+1]
    var v = rnd.nextDouble();
    v = v * 2.0 - 1.0;
    return v;
  }

  void doDiamondSquare(int stepsize, double scale)
  {
    int halfstep = stepsize ~/ 2;

    for (int y = halfstep; y < height + halfstep; y += stepsize)
    {
      for (int x = halfstep; x < width + halfstep; x += stepsize)
      {
        sampleSquare(x, y, stepsize, frand() * scale);
      }
    }

    for (int y = 0; y < height; y += stepsize)
    {
      for (int x = 0; x < width; x += stepsize)
      {
        sampleDiamond(x + halfstep, y, stepsize, frand() * scale);
        sampleDiamond(x, y + halfstep, stepsize, frand() * scale);
      }
    }
  }
}
