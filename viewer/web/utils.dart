library utils;

import 'dart:async';
import 'package:vector_math/vector_math.dart';
import 'package:three/three.dart';
import 'dart:math' as Math;


class Utils {

    static Future toFuture(dynamic v) {
        Completer c = new Completer();
        c.complete(v);
        return c.future;
    }

    static Vector3 vectorMin(Vector3 a, Vector3 b) {
        Vector3 c = new Vector3.zero();
        c.x = Math.min(a.x, b.x);
        c.y = Math.min(a.y, b.y);
        c.z = Math.min(a.z, b.z);
        return c;
    }

    static Vector3 vectorMax(Vector3 a, Vector3 b) {
        Vector3 c = new Vector3.zero();
        c.x = Math.max(a.x, b.x);
        c.y = Math.max(a.y, b.y);
        c.z = Math.max(a.z, b.z);
        return c;
    }

    static GeometryAttribute clone(GeometryAttribute src) {
        final int count = src.numItems;

        var dst = new GeometryAttribute.float32(count, 3);

        for (int i = 0; i < count; i++) {
            dst.array[i] = src.array[i];
        }

        return dst;
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
}
