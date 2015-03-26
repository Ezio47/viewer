// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend;


/// A point, represented by an (x,y,z) triple. No units or semantics are implied (as opposed
/// to the [Cartographic3] class).
class Cartesian3 {
    Vector3 _vector = new Vector3(0.0, 0.0, 0.0);

    Cartesian3(double x, double y, double z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    Cartesian3.zero();

    Cartesian3.fromVector(Vector3 v) : this(v.x, v.y, v.z);
    Cartesian3.fromList(List<num> v) : this(v[0].toDouble(), v[1].toDouble(), v[2].toDouble());

    Cartesian3.asMin() : this(-double.MAX_FINITE, -double.MAX_FINITE, -double.MAX_FINITE);
    Cartesian3.asMax() : this(double.MAX_FINITE, double.MAX_FINITE, double.MAX_FINITE);

    double get x => _vector.x;
    set x(double value) => _vector.x = value;
    double get y => _vector.y;
    set y(double value) => _vector.y = value;
    double get z => _vector.z;
    set z(double value) => _vector.z = value;
}


class CartesianBbox {
    Cartesian3 min;
    Cartesian3 max;

    CartesianBbox() {
        min = new Cartesian3.asMax();
        max = new Cartesian3.asMin();
    }
}
