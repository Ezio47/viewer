// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class Cartographic3 {
    Vector3 _vector = new Vector3(0.0, 0.0, 0.0);

    Cartographic3(double longitude, double latitude, double height) {
        this.longitude = longitude;
        this.latitude = latitude;
        this.height = height;
    }

    Cartographic3.zero();

    Cartographic3.asMin() : this(-180.0, -90.0, -double.MAX_FINITE);
    Cartographic3.asMax() : this(180.0, 90.0, double.MAX_FINITE);

    Cartographic3.fromVector3(Vector3 v) : this(v.x, v.y, v.z);
    Cartographic3.fromList(List<num> v) : this(v[0].toDouble(), v[1].toDouble(), v[2].toDouble());

    double get longitude => _vector.x;
    set longitude(double value) => _vector.x = value;
    double get latitude => _vector.y;
    set latitude(double value) => _vector.y = value;
    double get height => _vector.z;
    set height(double value) => _vector.z = value;
}


class CartographicBbox {
    Cartographic3 minimum;
    Cartographic3 maximum;

    CartographicBbox(Cartographic3 this.minimum, Cartographic3 this.maximum);

    CartographicBbox.empty() {
        minimum = new Cartographic3.asMax();
        maximum = new Cartographic3.asMin();
    }

    factory CartographicBbox.fromList(List<num> list) {
        if (list == null || list.length != 6) { // BUG: should error check
            return new CartographicBbox.empty();
        }
        var min = new Cartographic3.fromList(list.take(3).toList());
        var max = new Cartographic3.fromList(list.skip(3).toList());
        return new CartographicBbox(min, max);
    }
}
