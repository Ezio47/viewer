library cloud_generator;

import 'dart:core';
import 'package:three/three.dart';
import 'dart:math' as Math;
import 'dart:typed_data';


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
  static Map<String, Float32List> generate(String name)
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


  static Map<String, Float32List> makeNewCube()
  {
    num particles = 50000;

    Map<String, Float32List> map = new Map();

    var positionsX = new Float32List(particles);
    var positionsY = new Float32List(particles);
    var positionsZ = new Float32List(particles);
    var colorsX = new Float32List(particles);
    var colorsY = new Float32List(particles);
    var colorsZ = new Float32List(particles);

    map["positions.x"] = positionsX;
    map["positions.y"] = positionsY;
    map["positions.z"] = positionsZ;
    map["colors.x"] = colorsX;
    map["colors.y"] = colorsY;
    map["colors.z"] = colorsZ;

    var rnd = new Math.Random();

    var color = new Color();

    var n = 1000.0, n2 = n / 2.0; // particles spread in the cube

    for (var i = 0; i < particles; i++) {

      // positions
      var x = rnd.nextDouble() * n - n2;   // -500..+500
      var y = rnd.nextDouble() * n - n2;
      var z = rnd.nextDouble() * n - n2;
      assert(x>=-500.0 && y>=-500.0 && z>=-500.0);
      assert(x<=500.0 && y<=500.0 && z<=500.0);
      //print("$x $y $z");

      positionsX[i] = x;
      positionsY[i] = y;
      positionsZ[i] = z;

      // colors
      var vx = ( x / n ) + 0.5;
      var vy = ( y / n ) + 0.5;
      var vz = ( z / n ) + 0.5;

      color.setRGB( vx, vy, vz );

      //colors.array[ i ]     = color.r;
      //colors.array[ i ] = color.g;
      //colors.array[ i ] = color.b;

      if (x < 0.0 && y < 0.0 && z < 0.0)
      {
        // red at -5,-5,-5
        colorsX[i] = 1.0;
        colorsY[i] = 0.0;
        colorsZ[i] = 0.0;
        //print("$x $y $z");
      }
      else if (x > 0.0 && y > 0.0 && z> 0.0)
      {
        // blue at +5,+5,+5
        colorsX[i] = 0.0;
        colorsY[i] = 0.0;
        colorsZ[i] = 1.0;
      }
      else
      {
        colorsX[i] = 0.0;
        colorsY[i] = 0.0;
        colorsZ[i] = 0.0;
      }
    }

    return map;
  }


  static Map<String, Float32List> makeOldCube()
  {
    Map<String, Float32List> map = new Map();

    var numPoints = 24;

    var xx = new Float32List(numPoints);
    var yy = new Float32List(numPoints);
    var zz = new Float32List(numPoints);
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
      xx[i] = points[i*3];
      yy[i] = points[i*3+1];
      zz[i] = points[i*3+2];
    }

    return map;
  }


  static Map<String, Float32List> makeRandom()
  {
    Map<String, Float32List> map = new Map();

    var numPoints = 50000;

    var positionsX = new Float32List(numPoints);
    var positionsY = new Float32List(numPoints);
    var positionsZ = new Float32List(numPoints);
    map["positions.x"] = positionsX;
    map["positions.y"] = positionsY;
    map["positions.z"] = positionsZ;

    var xdim = 500;
    var ydim = 2000;
    var zdim = 1000;

    var random = new Math.Random();

    for (var i=0; i<numPoints; i++)
    {
      var x = random.nextDouble() * xdim;
      var y = random.nextDouble() * ydim;
      var z = random.nextDouble() * zdim;
      positionsX[i] = x;
      positionsY[i] = y;
      positionsZ[i] = z;
    }

    return map;
  }


  static Map<String, Float32List> makeLine()
  {
    Map<String, Float32List> map = new Map();

    var numPoints = 2000;

    var positionsX = new Float32List(numPoints);
    var positionsY = new Float32List(numPoints);
    var positionsZ = new Float32List(numPoints);

    map["positions.x"] = positionsX;
    map["positions.y"] = positionsY;
    map["positions.z"] = positionsZ;

    for (var i=0; i<numPoints; i++)
    {
      double pt = i.toDouble() / 10.0;
      positionsX[i] = pt;
      positionsY[i] = pt;
      positionsZ[i] = pt;
    }

    return map;
  }


  static Map<String, Float32List> makeTerrain()
  {
    Terrain terrain = new Terrain();

    Map<String, Float32List> map = new Map();
    map["positions.x"] = terrain.valuesX;
    map["positions.y"] = terrain.valuesY;
    map["positions.z"] = terrain.valuesZ;

    return map;
  }
}


// http://www.bluh.org/code-the-diamond-square-algorithm/
class Terrain
{
  int width, height;
  var valuesX, valuesY, valuesZ;
  var _valuesW;
  var rnd = new Math.Random();

  Terrain()
  {
    width = 512;
    height = 512;
    _valuesW = new Float32List(width*height);

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

    valuesX = new Float32List(width*height);
    valuesY = new Float32List(width*height);
    valuesZ = new Float32List(width*height);
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

        valuesX[i] = x;
        valuesY[i] = y;
        valuesZ[i] = z;
        i++;
      }
    }

  }

  double getSample(int x, int y)
  {
    x = x & (width - 1);
    y = y & (height - 1);
    return _valuesW[x + y * width];
  }

  void setSample(int x, int y, double value)
  {
    x = x & (width - 1);
    y = y & (height - 1);
    _valuesW[x + y * width] = value;
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