library point_cloud_generator;

import 'dart:core';
import 'package:three/three.dart';
import 'dart:math' as Math;
import 'dart:typed_data';
import 'point_cloud.dart';
import 'rialto_exceptions.dart';


// this class pretends to represent a pointcloud file: all it does is
// return a set of points, like a file would
//
// we assume each file will return at least dims for x, y, and z (or 'positions')

class PointCloudGenerator {

    static PointCloud generate(String name) {
        switch (name) {
            case "line.dat":
                return makeLine();
            case "newcube.dat":
                return makeNewCube();
            case "oldcube.dat":
                return makeOldCube();
            case "random.dat":
                return makeRandom();
            case "terrain1.dat":
                return makeTerrain(1);
            case "terrain2.dat":
                return makeTerrain(2);
            case "terrain3.dat":
                return makeTerrain(3);
        }
        throw new RialtoArgumentError("invalid file name");
    }


    static PointCloud makeNewCube() {
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

        var n = 1000.0,
                n2 = n / 2.0; // particles spread in the cube

        for (var i = 0; i < particles; i++) {

            // positions
            var x = rnd.nextDouble() * n - n2; // -500..+500
            var y = rnd.nextDouble() * n - n2;
            var z = rnd.nextDouble() * n - n2;
            assert(x >= -500.0 && y >= -500.0 && z >= -500.0);
            assert(x <= 500.0 && y <= 500.0 && z <= 500.0);
            //print("$x $y $z");

            positionsX[i] = x;
            positionsY[i] = y;
            positionsZ[i] = z;

            // colors
            var vx = (x / n) + 0.5;
            var vy = (y / n) + 0.5;
            var vz = (z / n) + 0.5;

            color.setRGB(vx, vy, vz);

            //colors.array[ i ]     = color.r;
            //colors.array[ i ] = color.g;
            //colors.array[ i ] = color.b;

            if (x < 0.0 && y < 0.0 && z < 0.0) {
                // red at -5,-5,-5
                colorsX[i] = 1.0;
                colorsY[i] = 0.0;
                colorsZ[i] = 0.0;
                //print("$x $y $z");
            } else if (x > 0.0 && y > 0.0 && z > 0.0) {
                // blue at +5,+5,+5
                colorsX[i] = 0.0;
                colorsY[i] = 0.0;
                colorsZ[i] = 1.0;
            } else {
                colorsX[i] = 0.0;
                colorsY[i] = 0.0;
                colorsZ[i] = 0.0;
            }
        }

        var cloud = new PointCloud("newcube");
        cloud.addDimensions(map);

        return cloud;
    }


    static PointCloud makeOldCube() {

        const double xmin = 200.0;
        const double xmax = 400.0;
        const double ymin = 200.0;
        const double ymax = 400.0;
        const double zmin = 200.0;
        const double zmax = 400.0;

        const double x0 = xmin;
        const double x1 = xmin + (xmax - xmin) * 0.25;
        const double x2 = xmin + (xmax - xmin) * 0.5;
        const double x3 = xmin + (xmax - xmin) * 0.75;
        const double x4 = xmin + (xmax - xmin);

        const double y2 = ymin + (ymax - ymin) * 0.5;
        const double z2 = zmin + (zmax - zmin) * 0.5;

        // x = red
        // y = green
        // z = blue

        List points = [];

        points.addAll([x0, ymin, zmin]);
        points.addAll([x0*1.05, ymin*1.05, zmin]);
        points.addAll([x0*1.10, ymin*1.10, zmin]);
        points.addAll([x0, ymin*1.05, zmin*1.05]);
        points.addAll([x0, ymin*1.10, zmin*1.10]);
        points.addAll([x0*1.05, ymin, zmin*1.05]);
        points.addAll([x0*1.10, ymin, zmin*1.10]);
        points.addAll([x1, ymin, zmin]);
        points.addAll([x2, ymin, zmin]);
        points.addAll([x3, ymin, zmin]);
        points.addAll([x4, ymin, zmin]);

        points.addAll([x0, ymax, zmin]);
        points.addAll([x1, ymax, zmin]);
        points.addAll([x2, ymax, zmin]);
        points.addAll([x3, ymax, zmin]);
        points.addAll([x4, ymax, zmin]);

        points.addAll([x0, ymin, zmax]);
        points.addAll([x1, ymin, zmax]);
        points.addAll([x2, ymin, zmax]);
        points.addAll([x3, ymin, zmax]);
        points.addAll([x4, ymin, zmax]);

        points.addAll([x0, ymax, zmax]);
        points.addAll([x1, ymax, zmax]);
        points.addAll([x2, ymax, zmax]);
        points.addAll([x3, ymax, zmax]);
        //points.addAll([x4, ymax, zmax]);

        points.addAll([x2, y2, y2]);

        final int numPoints = points.length ~/ 3;

        var x = new Float32List(numPoints);
        var y = new Float32List(numPoints);
        var z = new Float32List(numPoints);

        for (int i = 0; i < numPoints; i++) {
            x[i] = points[i * 3];
            y[i] = points[i * 3 + 1];
            z[i] = points[i * 3 + 2];
        }

        Map<String, Float32List> map = new Map();
        map["positions.x"] = x;
        map["positions.y"] = y;
        map["positions.z"] = z;

        var cloud = new PointCloud("oldcube");
        cloud.addDimensions(map);

        return cloud;
    }


    static PointCloud makeRandom() {
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

        for (var i = 0; i < numPoints; i++) {
            var x = random.nextDouble() * xdim;
            var y = random.nextDouble() * ydim;
            var z = random.nextDouble() * zdim;
            positionsX[i] = x;
            positionsY[i] = y;
            positionsZ[i] = z;
        }

        var cloud = new PointCloud("random");
        cloud.addDimensions(map);

        return cloud;
    }


    static PointCloud makeLine() {
        Map<String, Float32List> map = new Map();

        var numPoints = 2000;

        var positionsX = new Float32List(numPoints);
        var positionsY = new Float32List(numPoints);
        var positionsZ = new Float32List(numPoints);

        map["positions.x"] = positionsX;
        map["positions.y"] = positionsY;
        map["positions.z"] = positionsZ;

        for (var i = 0; i < numPoints; i++) {
            double pt = i.toDouble() / 10.0;
            positionsX[i] = pt;
            positionsY[i] = pt;
            positionsZ[i] = pt;
        }

        var cloud = new PointCloud("line");
        cloud.addDimensions(map);

        return cloud;
    }


    static PointCloud makeTerrain(int which) {
        _Terrain terrain = new _Terrain(which);

        Map<String, Float32List> map = new Map();
        map["positions.x"] = terrain.valuesX;
        map["positions.y"] = terrain.valuesY;
        map["positions.z"] = terrain.valuesZ;

        var cloud = new PointCloud("terrain");
        cloud.addDimensions(map);

        return cloud;
    }
}


// http://www.bluh.org/code-the-diamond-square-algorithm/
class _Terrain {
    int width, height;
    var valuesX, valuesY, valuesZ;
    var _valuesW;
    var rnd = new Math.Random(new DateTime.now().millisecondsSinceEpoch);

    _Terrain(int which) {
        width = 512;
        height = 512;
        _valuesW = new Float32List(width * height);

        _generatePoints();

        valuesX = new Float32List(width * height);
        valuesY = new Float32List(width * height);
        valuesZ = new Float32List(width * height);

        double xoffset;
        double yoffset;
        switch (which) {
            case 1:
                xoffset = 0.0;
                yoffset = 0.0;
                break;
            case 2:
                xoffset = 400.0;
                yoffset = 400.0;
                break;
            case 3:
                xoffset = 550.0;
                yoffset = -150.0;
                break;
            default:
                throw new RialtoArgumentError("invalid terrain mode value");
        }

        _makeGrid(xoffset, yoffset);
    }

    void _makeGrid(double xoffset, double yoffset) {

        double minz = getSample(0, 0);
        for (int w = 0; w < width; w++) {
              for (int h = 0; h < height; h++) {
                  minz = Math.min(minz, getSample(w, h));
              }
        }

        double scale = 5.0;

        int i = 0;
        for (int w = 0; w < width; w++) {
            for (int h = 0; h < height; h++) {
                double x = w.toDouble();
                double y = h.toDouble();
                double z = getSample(w, h);

                // jiggle the (x,y) points, to prevent visual artifacts
                x += (rnd.nextDouble() - 0.5);
                y += (rnd.nextDouble() - 0.5);

                // for better viewing, center the data at zero and spread it out more
                x = (x - width / 2) * scale;
                y = (y - height / 2) * scale;

                if (w<width*0.1 && h<height*0.1) z = minz;

                // for better viewing, exaggerate Z
                z = z * 200.0;

                valuesX[i] = x + xoffset * scale;
                valuesY[i] = y + yoffset * scale;
                valuesZ[i] = z;
                i++;
            }
        }
    }

    void _generatePoints() {
        const int featuresize = 32;

        for (int y = 0; y < height; y += featuresize) {
            for (int x = 0; x < width; x += featuresize) {
                setSample(x, y, frand());

                //if (x>100 && x<200 && y>100 && y<200)
                //{
                // setSample(x,y,10.0);
                //}
            }
        }

        int samplesize = featuresize;
        double scale = 1.0;

        while (samplesize > 1) {
            doDiamondSquare(samplesize, scale);

            samplesize = samplesize ~/ 2;
            scale = scale / 2.0;
        }
    }

    double getSample(int x, int y) {
        x = x & (width - 1);
        y = y & (height - 1);
        return _valuesW[x + y * width];
    }

    void setSample(int x, int y, double value) {
        x = x & (width - 1);
        y = y & (height - 1);
        _valuesW[x + y * width] = value;
    }

    void sampleSquare(int x, int y, int size, double value) {
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

    void sampleDiamond(int x, int y, int size, double value) {
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

    double frand() {
        // return in range [-1..+1]
        var v = rnd.nextDouble();
        v = v * 2.0 - 1.0;
        return v;
    }

    void doDiamondSquare(int stepsize, double scale) {
        int halfstep = stepsize ~/ 2;

        for (int y = halfstep; y < height + halfstep; y += stepsize) {
            for (int x = halfstep; x < width + halfstep; x += stepsize) {
                sampleSquare(x, y, stepsize, frand() * scale);
            }
        }

        for (int y = 0; y < height; y += stepsize) {
            for (int x = 0; x < width; x += stepsize) {
                sampleDiamond(x + halfstep, y, stepsize, frand() * scale);
                sampleDiamond(x, y + halfstep, stepsize, frand() * scale);
            }
        }
    }
}
