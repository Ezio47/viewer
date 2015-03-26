// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


/// Representation of an RGBA color
class Color {
    double r, g, b, a;

    Color(this.r, this.g, this.b, {this.a: 0.0});

    Color.red() : this(1.0, 0.0, 0.0);
    Color.green() : this(0.0, 1.0, 0.0);
    Color.blue() : this(0.0, 0.0, 1.0);
    Color.yellow() : this(1.0, 1.0, 0.0);
    Color.black() : this(0.0, 0.0, 0.0);
    Color.white() : this(1.0, 1.0, 1.0);

    void setRGB(double rr, double gg, double bb) {
        r = rr;
        g = gg;
        b = bb;
        a = 1.0;
    }

    List<double> toList() {
        return [r, g, b, a];
    }
}
