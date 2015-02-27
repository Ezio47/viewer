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

    static Uri firstPart(Uri uri) {
        var scheme = uri.scheme;
        var userInfo = uri.userInfo;
        var host = uri.host;
        var port = uri.port;
        //var path = uri.path;
        //var query = uri.query;
        //var frag = uri.fragment;
        return new Uri(scheme: scheme, userInfo: userInfo, host: host, port: port);
    }

    static Uri secondPart(Uri uri) {
        //var scheme = uri.scheme;
        //var userInfo = uri.userInfo;
        //var host = uri.host;
        //var port = uri.port;
        var path = uri.path;
        var query = uri.query;
        var fragment = uri.fragment;
        return new Uri(path: path, query: query, fragment: fragment);
    }

    // Uint64 not supported in dart2js
    static int ByteData_getUint64(ByteData buf, int index, Endianness e) {
        assert(e == Endianness.LITTLE_ENDIAN);
        var lo = buf.getUint32(index, e);
        var hi = buf.getUint32(index + 4, e);
        return lo | (hi << 32);
    }

    static String toString_Vector3(Vector3 v, [int prec = 2]) {
        var s = Utils.toString_double3(v.x, v.y, v.z, prec);
        return s;
    }

    static String toString_Cartographic3(Cartographic3 v, [int prec = 2]) {
        var s = Utils.toString_double3(v.longitude, v.latitude, v.height, prec);
        return s;
    }

    static String toString_double3(double x, double y, double z, [int prec = 1]) {
        var s = "${x.toStringAsFixed(prec)},${y.toStringAsFixed(prec)},${z.toStringAsFixed(prec)}";
        return s;
    }

    static void vectorMinWith(Vector3 dst, Vector3 src) {
        Utils.vectorMinWith3(dst, src.x, src.y, src.z);
    }

    static void vectorMaxWith(Vector3 dst, Vector3 src) {
        Utils.vectorMaxWith3(dst, src.x, src.y, src.z);
    }

    static void vectorMinWith3(Vector3 dst, double x, double y, double z) {
        dst.x = min(dst.x, x);
        dst.y = min(dst.y, y);
        dst.z = min(dst.z, z);
    }

    static void vectorMaxWith3(Vector3 dst, double x, double y, double z) {
        dst.x = max(dst.x, x);
        dst.y = max(dst.y, y);
        dst.z = max(dst.z, z);
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
}
