// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// this class pretends to represent a pointcloud file: all it does is
// return a set of points, like a file would
//
// we assume each file will return at least dims for x, y, and z (or 'positions')

class PointCloudGenerator {

    static PointCloud fromRaw(Float32List floats, String webpath, String displayName) {
        final int numFloats = floats.length;
        final int numPoints = numFloats ~/ 3;

        Map<String, Float32List> map = new Map();

        var positionsX = new Float32List(numPoints);
        var positionsY = new Float32List(numPoints);
        var positionsZ = new Float32List(numPoints);
        map["positions.x"] = positionsX;
        map["positions.y"] = positionsY;
        map["positions.z"] = positionsZ;

        int i = 0;
        for (int di = 0; di < numFloats; di += 3) {
            var x = floats[di];
            var y = floats[di + 1];
            var z = floats[di + 2];
            positionsX[i] = x;
            positionsY[i] = y;
            positionsZ[i] = z;
            ++i;
        }

        var cloud = new PointCloud(webpath, displayName);
        cloud.createDimensions(map);

        //final cnt = Utils.toSI(numPoints);
        print("made $webpath: $numPoints points");

        return cloud;
    }

    static PointCloud generate(String webpath, String displayName) {
        switch (webpath) {
            case "/dir2/line.dat":
                return _makeLine(webpath, displayName);
            case "/newcube.dat":
                return _makeRandom(webpath, displayName);
            case "/oldcube.dat":
                return _makeRandom(webpath, displayName);
            case "/dir1/random.dat":
                return _makeRandom(webpath, displayName);
            case "/terrain1.dat":
                return _makeTerrain(1, webpath, displayName);
            case "/terrain2.dat":
                return _makeTerrain(2, webpath, displayName);
            case "/terrain3.dat":
                return _makeTerrain(3, webpath, displayName);
        }
        throw new RialtoArgumentError("invalid file name");
    }

    static PointCloud _makeRandom(String webpath, String displayName) {
        Map<String, Float32List> map = new Map();

        var numPoints = 10000;

        var positionsX = new Float32List(numPoints);
        var positionsY = new Float32List(numPoints);
        var positionsZ = new Float32List(numPoints);
        map["positions.x"] = positionsX;
        map["positions.y"] = positionsY;
        map["positions.z"] = positionsZ;;

        final lon = -77.62549459934235;
        final lat = 38.833895271724664;
        final xdelta = 0.25;
        final ydelta = 0.25;

        var xmin = lon - xdelta;
        var ymin = lat - ydelta;
        var zmin = 0.0;
        var xmax = lon + xdelta;
        var ymax = lat + ydelta;
        var zmax = 10000.0;

        var random = new Random(17);

        for (int i = 0; i < numPoints; i++) {
            double d = i.toDouble() / numPoints.toDouble();
            double x = random.nextDouble();
            double y = random.nextDouble();
            double z = random.nextDouble();

            //x = y = z = d;

            x = xmin + (xmax - xmin) * x;
            y = ymin + (ymax - ymin) * y;
            z = zmin + (zmax - zmin) * z;

            positionsX[i] = x;
            positionsY[i] = y;
            positionsZ[i] = z;
        }

        var cloud = new PointCloud(webpath, displayName);
        cloud.createDimensions(map);

        return cloud;
    }

    static PointCloud _makeLine(String webpath, String displayName) {
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

        var cloud = new PointCloud(webpath, displayName);
        cloud.createDimensions(map);

        return cloud;
    }

    static PointCloud _makeTerrain(int which, String webpath, String displayName) {
        _Terrain terrain = new _Terrain(which);

        Map<String, Float32List> map = new Map();
        map["positions.x"] = terrain.valuesX;
        map["positions.y"] = terrain.valuesY;
        map["positions.z"] = terrain.valuesZ;

        var cloud = new PointCloud(webpath, displayName);
        cloud.createDimensions(map);

        return cloud;
    }
}


// http://www.bluh.org/code-the-diamond-square-algorithm/
class _Terrain {
    int width, height;
    var valuesX, valuesY, valuesZ;
    var _valuesW;
    var rnd = new Random(new DateTime.now().millisecondsSinceEpoch);

    _Terrain(int which) {
        width = 512;
        height = 512;
        _valuesW = new Float32List(width * height);

        _generatePoints();

        valuesX = new Float32List(width * height);
        valuesY = new Float32List(width * height);
        valuesZ = new Float32List(width * height);

        double xmin;
        double ymin;
        double xlen = 0.20;
        double ylen = 0.20;
        double zscale;

        switch (which) {
            case 0:
                xmin = 0.0;
                ymin = 0.0;
                xlen = 1.0;
                ylen = 1.0;
                break;
            case 1:
                xmin = -77.62549459934235;
                ymin = 38.833895271724664;
                xlen = 0.05;
                ylen = 0.05;
                zscale = 250.0;
                break;
            default:
                throw new RialtoArgumentError("invalid terrain mode value");
        }

        _makeGrid(xmin, ymin, xlen, ylen, zscale);
    }

    void _makeGrid(double xmin, double ymin, double xlen, double ylen, double zscale) {

        double minz = getSample(0, 0);
        for (int w = 0; w < width; w++) {
            for (int h = 0; h < height; h++) {
                minz = min(minz, getSample(w, h));
            }
        }

        int i = 0;
        for (int w = 0; w < width; w++) {
            for (int h = 0; h < height; h++) {
                double x = w.toDouble();
                double y = h.toDouble();
                double z = getSample(w, h);

                // jiggle the (x,y) points, to prevent visual artifacts
                x -= rnd.nextDouble();
                y -= rnd.nextDouble();

                // make the min corner artificially stand out
                if (w < width * 0.1 && h < height * 0.1) z = minz;

                // x: [0, width)
                // y: [0, height)
                x = xmin + x / width.toDouble() * xlen;
                y = ymin + y / height.toDouble() * ylen;

                // x: [, width)
                // y: [0, height)
                valuesX[i] = x;
                valuesY[i] = y;
                valuesZ[i] = z * zscale;
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
