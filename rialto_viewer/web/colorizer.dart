// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

abstract class Colorizer {
    Colorizer();

    void run(RenderablePointCloud cloud) {
        _algorithm(
                cloud.min.z,
                cloud.max.z,
                cloud.dims["positions"].array,
                cloud.dims["colors"].array,
                cloud.numPoints);
    }

    void _algorithm(double zmin, double zmax, Float32List positions, Float32List colors, int numPoints);
}


class FauxColorizer extends Colorizer {

    void _algorithm(double zmin, double zmax, Float32List positions, Float32List colors, int numPoints) {
        double zLen = zmax - zmin;

        for (int i = 0; i < numPoints * 3; i += 3) {
            double z = positions[i + 2];
            double c = (z - zmin) / zLen;

            // clip, due to FP math
            assert(c >= -0.1 && c <= 1.1);
            if (c < 0.0) c = 0.0;
            if (c > 1.0) c = 1.0;

            // a silly ramp
            if (c < 0.3333) {
                colors[i] = c * 3.0;
                colors[i + 1] = 0.0;
                colors[i + 2] = 0.0;
            } else if (c < 0.6666) {
                colors[i] = 0.0;
                colors[i + 1] = (c - 0.3333) * 3.0;
                colors[i + 2] = 0.0;
            } else {
                colors[i] = 0.0;
                colors[i + 1] = 0.0;
                colors[i + 2] = (c - 0.6666) * 3.0;
            }
        }
    }
}


class RampColorizer extends Colorizer {
    final String _name;
    RampColorizer(this._name);

    void _algorithm(double zmin, double zmax, Float32List positions, Float32List colors, int numPoints) {
        assert(_Ramps.list.containsKey(_name));

        final double zLen = zmax - zmin;

        for (int i = 0; i < numPoints * 3; i += 3) {
            double z = positions[i + 2];
            double scaledZ = (z - zmin) / zLen;

            // clip, due to FP math
            assert(scaledZ >= -0.1 && scaledZ <= 1.1);
            if (scaledZ < 0.0) scaledZ = 0.0;
            if (scaledZ > 1.0) scaledZ = 1.0;

            final List<_Stop> stops = _Ramps.list[_name];
            assert(stops.length>=2);
            assert(stops[0].point==0.0);
            assert(stops[stops.length-1].point==1.0);

            double startRange = stops[0].point;
            double endRange;
            _Color result = null;
            for (int s = 1; s < stops.length; s++) {
                endRange = stops[s].point;

                if (scaledZ >= startRange && scaledZ <= endRange) {
                    result = _interpolate(scaledZ, startRange, endRange, stops[s-1].color, stops[s].color);
                    break;
                }

                startRange = endRange;
            }
            assert(result != null);

            colors[i + 0] = result.r / 255.0;
            colors[i + 1] = result.g / 255.0;
            colors[i + 2] = result.b / 255.0;
        }
    }

    _Color _interpolate(double z, double startRange, double endRange, _Color startColor, _Color endColor) {
        final double scale = (z - startRange) / (endRange - startRange);
        assert(scale>=0.0 && scale<=1.0);

        final double r = scale * (endColor.r - startColor.r) + startColor.r;
        final double g = scale * (endColor.g - startColor.g) + startColor.g;
        final double b = scale * (endColor.b - startColor.b) + startColor.b;
        assert(r>=0.0 && r<=255.0);
        assert(g>=0.0 && g<=255.0);
        assert(b>=0.0 && b<=255.0);

        final int ri = r.toInt();
        final int gi = g.toInt();
        final int bi = b.toInt();

        assert(ri>=0.0 && ri<=255);
        assert(gi>=0.0 && gi<=255);
        assert(bi>=0.0 && bi<=255);

        return new _Color(ri, gi, bi);
    }
}


class _Color {
    final int r, g, b;
    const _Color(this.r, this.g, this.b);
}

class _Stop {
    final double point;
    final _Color color;
    const _Stop(this.point, this.color);
}


class _Ramps {
    // These ramps are taken from http://planet.qgis.org/planet/tag/color%20ramps/
    // (there are some more at http://geotrellis.io/documentation/0.9.0/geotrellis/rendering/)
    static final list = {
        "Blues": [
                const _Stop(0.00, const _Color(247, 251, 255)),
                const _Stop(0.13, const _Color(222, 235, 247)),
                const _Stop(0.26, const _Color(198, 219, 239)),
                const _Stop(0.39, const _Color(158, 202, 225)),
                const _Stop(0.52, const _Color(107, 174, 214)),
                const _Stop(0.65, const _Color(66, 146, 198)),
                const _Stop(0.78, const _Color(33, 113, 181)),
                const _Stop(0.90, const _Color(8, 81, 156)),
                const _Stop(1.00, const _Color(8, 48, 107))],
        "BrBG": [
                const _Stop(0.00, const _Color(166, 97, 26)),
                const _Stop(0.25, const _Color(223, 194, 125)),
                const _Stop(0.5, const _Color(245, 245, 245)),
                const _Stop(0.75, const _Color(128, 205, 193)),
                const _Stop(1.00, const _Color(1, 133, 113))],
        "BuGn": [
                const _Stop(0.00, const _Color(237, 248, 251)),
                const _Stop(0.25, const _Color(178, 226, 226)),
                const _Stop(0.50, const _Color(102, 194, 164)),
                const _Stop(0.75, const _Color(44, 162, 95)),
                const _Stop(1.00, const _Color(0, 109, 44))],
        "BuPu": [
                const _Stop(0.00, const _Color(237, 248, 251)),
                const _Stop(0.25, const _Color(179, 205, 227)),
                const _Stop(0.50, const _Color(140, 150, 198)),
                const _Stop(0.75, const _Color(136, 86, 167)),
                const _Stop(1.00, const _Color(129, 15, 124))],
        "GnBu": [
                const _Stop(0.00, const _Color(240, 249, 232)),
                const _Stop(0.25, const _Color(186, 228, 188)),
                const _Stop(0.50, const _Color(123, 204, 196)),
                const _Stop(0.75, const _Color(67, 162, 202)),
                const _Stop(1.00, const _Color(8, 104, 172))],
        "Greens": [
                const _Stop(0.00, const _Color(247, 252, 245)),
                const _Stop(0.13, const _Color(229, 245, 224)),
                const _Stop(0.26, const _Color(199, 233, 192)),
                const _Stop(0.39, const _Color(161, 217, 155)),
                const _Stop(0.52, const _Color(116, 196, 118)),
                const _Stop(0.65, const _Color(65, 171, 93)),
                const _Stop(0.78, const _Color(35, 139, 69)),
                const _Stop(0.90, const _Color(0, 109, 44)),
                const _Stop(1.00, const _Color(0, 68, 27))],
        "Greys": [const _Stop(0.00, const _Color(250, 250, 250)), const _Stop(1.00, const _Color(5, 5, 5))],
        "OrRd": [
                const _Stop(0.00, const _Color(254, 240, 217)),
                const _Stop(0.25, const _Color(253, 204, 138)),
                const _Stop(0.50, const _Color(252, 141, 89)),
                const _Stop(0.75, const _Color(227, 74, 51)),
                const _Stop(1.00, const _Color(179, 0, 0))],
        "Oranges": [
                const _Stop(0.00, const _Color(255, 245, 235)),
                const _Stop(0.13, const _Color(254, 230, 206)),
                const _Stop(0.26, const _Color(253, 208, 162)),
                const _Stop(0.39, const _Color(253, 174, 107)),
                const _Stop(0.52, const _Color(253, 141, 60)),
                const _Stop(0.65, const _Color(241, 105, 19)),
                const _Stop(0.78, const _Color(217, 72, 1)),
                const _Stop(0.90, const _Color(166, 54, 3)),
                const _Stop(1.00, const _Color(127, 39, 4))],
        "PRGn": [
                const _Stop(0.00, const _Color(123, 50, 148)),
                const _Stop(0.25, const _Color(194, 165, 207)),
                const _Stop(0.50, const _Color(247, 247, 247)),
                const _Stop(0.75, const _Color(166, 219, 160)),
                const _Stop(1.00, const _Color(0, 136, 55))],
        "PiYG": [
                const _Stop(0.00, const _Color(208, 28, 139)),
                const _Stop(0.25, const _Color(241, 182, 218)),
                const _Stop(0.50, const _Color(247, 247, 247)),
                const _Stop(0.75, const _Color(184, 225, 134)),
                const _Stop(1.00, const _Color(77, 172, 38))],
        "PuBu": [
                const _Stop(0.00, const _Color(241, 238, 246)),
                const _Stop(0.25, const _Color(189, 201, 225)),
                const _Stop(0.50, const _Color(116, 169, 207)),
                const _Stop(0.75, const _Color(43, 140, 190)),
                const _Stop(1.00, const _Color(4, 90, 141))],
        "PuBuGn": [
                const _Stop(0.00, const _Color(246, 239, 247)),
                const _Stop(0.25, const _Color(189, 201, 225)),
                const _Stop(0.50, const _Color(103, 169, 207)),
                const _Stop(0.75, const _Color(28, 144, 153)),
                const _Stop(1.00, const _Color(1, 108, 89))],
        "PuOr": [
                const _Stop(0.00, const _Color(230, 97, 1)),
                const _Stop(0.25, const _Color(253, 184, 99)),
                const _Stop(0.50, const _Color(247, 247, 247)),
                const _Stop(0.75, const _Color(178, 171, 210)),
                const _Stop(1.00, const _Color(94, 60, 153))],
        "PuRd": [
                const _Stop(0.00, const _Color(241, 238, 246)),
                const _Stop(0.25, const _Color(215, 181, 216)),
                const _Stop(0.50, const _Color(223, 101, 176)),
                const _Stop(0.75, const _Color(221, 28, 119)),
                const _Stop(1.00, const _Color(152, 0, 67))],
        "Purples": [
                const _Stop(0.00, const _Color(252, 251, 253)),
                const _Stop(0.13, const _Color(239, 237, 245)),
                const _Stop(0.26, const _Color(218, 218, 235)),
                const _Stop(0.39, const _Color(188, 189, 220)),
                const _Stop(0.52, const _Color(158, 154, 200)),
                const _Stop(0.65, const _Color(128, 125, 186)),
                const _Stop(0.75, const _Color(106, 81, 163)),
                const _Stop(0.90, const _Color(84, 39, 143)),
                const _Stop(1.00, const _Color(63, 0, 125))],
        "RdBu": [
                const _Stop(0.00, const _Color(202, 0, 32)),
                const _Stop(0.25, const _Color(244, 165, 130)),
                const _Stop(0.50, const _Color(247, 247, 247)),
                const _Stop(0.75, const _Color(146, 197, 222)),
                const _Stop(1.00, const _Color(5, 113, 176))],
        "RdGy": [
                const _Stop(0.00, const _Color(202, 0, 32)),
                const _Stop(0.25, const _Color(244, 165, 130)),
                const _Stop(0.50, const _Color(255, 255, 255)),
                const _Stop(0.75, const _Color(186, 186, 186)),
                const _Stop(1.00, const _Color(64, 64, 64))],
        "RdPu": [
                const _Stop(0.00, const _Color(254, 235, 226)),
                const _Stop(0.25, const _Color(251, 180, 185)),
                const _Stop(0.50, const _Color(247, 104, 161)),
                const _Stop(0.75, const _Color(197, 27, 138)),
                const _Stop(1.00, const _Color(122, 1, 119))],
        "RdYlBu": [
                const _Stop(0.00, const _Color(215, 25, 28)),
                const _Stop(0.25, const _Color(253, 174, 97)),
                const _Stop(0.50, const _Color(255, 255, 191)),
                const _Stop(0.75, const _Color(171, 217, 233)),
                const _Stop(1.00, const _Color(44, 123, 182))],
        "RdYlGn": [
                const _Stop(0.00, const _Color(215, 25, 28)),
                const _Stop(0.25, const _Color(253, 174, 97)),
                const _Stop(0.50, const _Color(255, 255, 192)),
                const _Stop(0.75, const _Color(166, 217, 106)),
                const _Stop(1.00, const _Color(26, 150, 65))],
        "Reds": [
                const _Stop(0.00, const _Color(255, 245, 240)),
                const _Stop(0.13, const _Color(254, 224, 210)),
                const _Stop(0.26, const _Color(252, 187, 161)),
                const _Stop(0.39, const _Color(252, 146, 114)),
                const _Stop(0.52, const _Color(251, 106, 74)),
                const _Stop(0.65, const _Color(239, 59, 44)),
                const _Stop(0.78, const _Color(203, 24, 29)),
                const _Stop(0.90, const _Color(165, 15, 21)),
                const _Stop(1.00, const _Color(103, 0, 13))],
        "Spectral": [
                const _Stop(0.00, const _Color(215, 25, 28)),
                const _Stop(0.25, const _Color(253, 174, 97)),
                const _Stop(0.50, const _Color(255, 255, 191)),
                const _Stop(0.75, const _Color(171, 221, 164)),
                const _Stop(1.00, const _Color(43, 131, 186))],
        "YlGn": [
                const _Stop(0.00, const _Color(255, 255, 204)),
                const _Stop(0.25, const _Color(194, 230, 153)),
                const _Stop(0.50, const _Color(120, 198, 121)),
                const _Stop(0.75, const _Color(49, 163, 84)),
                const _Stop(1.00, const _Color(0, 104, 55))],
        "YlGnBu": [
                const _Stop(0.00, const _Color(255, 255, 204)),
                const _Stop(0.25, const _Color(161, 218, 180)),
                const _Stop(0.50, const _Color(65, 182, 196)),
                const _Stop(0.75, const _Color(44, 127, 184)),
                const _Stop(1.00, const _Color(37, 52, 148))],
        "YlOrBr": [
                const _Stop(0.00, const _Color(255, 255, 212)),
                const _Stop(0.25, const _Color(254, 217, 142)),
                const _Stop(0.50, const _Color(254, 153, 41)),
                const _Stop(0.75, const _Color(217, 95, 14)),
                const _Stop(1.00, const _Color(153, 52, 4))],
        "YlOrRd": [
                const _Stop(0.00, const _Color(255, 255, 178)),
                const _Stop(0.25, const _Color(254, 204, 92)),
                const _Stop(0.50, const _Color(253, 141, 60)),
                const _Stop(0.75, const _Color(240, 59, 32)),
                const _Stop(1.00, const _Color(189, 0, 38))]
    };
}
