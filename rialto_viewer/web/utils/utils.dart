// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


num min3(num a, num b, num c) => min(min(a, b), c);
num max3(num a, num b, num c) => max(max(a, b), c);
num degToRad(num deg) => deg * (PI / 180.0);
num radToDeg(num rad) => rad * (180.0 / PI);
num clamp(num v, num low, num high) => (v < low) ? low : ((v > high) ? high : v);
num clamp360(num degrees) => (degrees > 360 || degrees < -360) ? degrees % 360 : degrees;


class Key {
    static const int UP = 38;
    static const int DOWN = 40;
    static const int RIGHT = 39;
    static const int LEFT = 37;
    static const int A = 65;
    static const int D = 68;
    static const int N = 78;
    static const int S = 83;
    static const int W = 87;
    static const int PLUS = 187;
    static const int MINUS = 189;
}


class Utils {
    static String printv(Vector3 v, [int prec = 2]) {
        var s = Utils.printv3(v.x, v.y, v.z, prec);
        return s;
    }

    static String printv3(double x, double y, double z, [int prec = 1]) {
        var s = "${x.toStringAsFixed(prec)},${y.toStringAsFixed(prec)},${z.toStringAsFixed(prec)}";
        return s;
    }

    static Future toFuture(dynamic v) {
        Completer c = new Completer();
        c.complete(v);
        return c.future;
    }

    static Vector3 vectorMinV(Vector3 a, Vector3 b) {
        Vector3 c = new Vector3.zero();
        c.x = min(a.x, b.x);
        c.y = min(a.y, b.y);
        c.z = min(a.z, b.z);
        return c;
    }

    static Vector3 vectorMaxV(Vector3 a, Vector3 b) {
        Vector3 c = new Vector3.zero();
        c.x = max(a.x, b.x);
        c.y = max(a.y, b.y);
        c.z = max(a.z, b.z);
        return c;
    }

    static double vectorMinD(Vector3 a) {
        var d = min3(a.x, a.y, a.z);
        return d;
    }

    static double vectorMaxD(Vector3 a) {
        var d = max3(a.x, a.y, a.z);
        return d;
    }

    static String toSI(num vv, {sigfigs: 0}) {
        double v = vv.toDouble();
        const double K = 1000.0;
        const double M = K * K;
        const double G = K * K * K;

        if (v >= G) {
            v = v / G;
            return "${v.toStringAsFixed(sigfigs)}G";
        }

        if (v >= M) {
            v = v / M;
            return "${v.toStringAsFixed(sigfigs)}M";
        }

        if (v >= K) {
            v = v / K;
            return "${v.toStringAsFixed(sigfigs)}K";
        }

        return "$v";
    }

    static test_toSI() {
        assert(toSI(4) == "4");
        assert(toSI(999) == "999");
        assert(toSI(1000) == "1K");
        assert(toSI(1001) == "1K");
        assert(toSI(10000) == "10K");
        assert(toSI(999000) == "999K");
        assert(toSI(1000000) == "1M");
        assert(toSI(1000000000) == "1G");
    }

    static Vector3 getCameraPointTarget(RenderablePointCloudSet set) {

        double minx = 0.0;
        double miny = 0.0;
        double minz = 0.0;
        double lenx = 100.0;
        double leny = 100.0;

        if (set.length > 0) {
            minx = set.min.x;
            miny = set.min.y;
            minz = set.min.z;
            lenx = set.len.x;
            leny = set.len.y;
        }

        final double x = minx + lenx / 2.0;
        final double y = miny + leny / 2.0;
        final double z = minz;

        return new Vector3(x, y, z);
    }

    static Vector3 getCameraPointEye(RenderablePointCloudSet set) {

        double lenx = 100.0;
        double leny = 100.0;
        double maxz = 25.0;

        if (set.length > 0) {
            lenx = set.len.x;
            leny = set.len.y;
            maxz = set.max.z;

        }

        var v = getCameraPointTarget(set);

        v.x = v.x - 0.5 * lenx;
        v.y = v.y - 1.25 * leny;
        v.z = maxz * 5.0;

        return v;
    }
}
