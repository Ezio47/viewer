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

    Cartographic3.fromVector3(Vector3 v) : this(v.x, v.y, v.z);

    double get longitude => _vector.x;
    set longitude(double value) => _vector.x = value;
    double get latitude => _vector.y;
    set latitude(double value) => _vector.y = value;
    double get height => _vector.z;
    set height(double value) => _vector.z = value;
}
