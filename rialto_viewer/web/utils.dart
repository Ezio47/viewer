// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


num min3(num a, num b, num c) => min(min(a, b), c);
num max3(num a, num b, num c) => max(max(a, b), c);
num degToRad(num deg) => deg * (PI / 180.0);
num radToDeg(num rad) => rad * (180.0 / PI);
num clamp(num v, num low, num high) => (v < low) ? low : ((v > high) ? high : v);
num clamp360(num degrees) => (degrees > 360 || degrees < -360) ? degrees % 360 : degrees;


class Utils {
    static String printv(Vector3 v, [int prec=1]) {
        var s = Utils.printv3(v.x, v.y, v.z, prec);
        return s;
    }

    static String printv3(double x, double y, double z, [int prec=1]) {
        var s = "${x.toStringAsFixed(prec)},${y.toStringAsFixed(prec)},${z.toStringAsFixed(prec)}";
        return s;
    }

    static bool _checkInts(int r, int g, int b) => (r >= 0 && r <= 255) && (g >= 0 && g <= 255) && (b >= 0 && b <= 255);
    static bool _checkFloats(double r, double g, double b) =>
            (r >= 0.0 && r <= 1.0) && (g >= 0.0 && g <= 1.0) && (b >= 0.0 && b <= 1.0);
    static bool _checkId(int id) => (id >= 0 && id < 256 * 256 * 256);

    static int convertFvecToId(Float32List list) {
        final double rf = list[0];
        final double gf = list[1];
        final double bf = list[2];
        assert(_checkFloats(rf, gf, bf));

        final int ri = (rf * 256.0).toInt();
        final int gi = (gf * 256.0).toInt();
        final int bi = (bf * 256.0).toInt();
        assert(_checkInts(ri, gi, bi));

        final int id = (bi << 16) | (gi << 8) | ri;
        assert(_checkId(id));

        return id;
    }

    static int convertIvecToId(int ri, int gi, int bi) {
        assert(_checkInts(ri, gi, bi));

        final int id = (bi << 16) | (gi << 8) | ri;
        assert(_checkId(id));

        return id;
    }

    static Float32List convertIdToFvec(int id) {
        assert(_checkId(id));

        final int ri = id & 0x0000ff;
        final int gi = (id & 0x00ff00) >> 8;
        final int bi = (id & 0xff0000) >> 16;
        assert(_checkInts(ri, gi, bi));

        final double rf = ri / 256.0;
        final double gf = gi / 256.0;
        final double bf = bi / 256.0;
        assert(_checkFloats(rf, gf, bf));

        var list = new Float32List.fromList([rf, gf, bf, 1.0]);
        assert(convertFvecToId(list) == id);
        //print("MAP $id => $rf $gf $bf == ${(rf*256.0).toInt()} ${(gf*256.0).toInt()} ${(bf*256.0).toInt()}");
        return list;
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

    static String toSI(num vv, {sigfigs:0}) {
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
