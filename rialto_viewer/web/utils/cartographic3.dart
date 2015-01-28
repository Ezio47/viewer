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

    void minWith(Cartographic3 v) => Utils.vectorMinWith(_vector, v._vector);
    void maxWith(Cartographic3 v) => Utils.vectorMaxWith(_vector, v._vector);
}


class CartographicBbox {
    Cartographic3 minimum;
    Cartographic3 maximum;

    CartographicBbox(Cartographic3 this.minimum, Cartographic3 this.maximum);

    CartographicBbox.empty() {
        minimum = new Cartographic3.asMax();
        maximum = new Cartographic3.asMin();
    }

    CartographicBbox.fromValues(double minx, double miny, double minz, double maxx, double maxy, double maxz) {
        minimum = new Cartographic3(minx, miny, minz);
        maximum = new Cartographic3(maxx, maxy, maxz);
    }

    bool get isValid => minimum._vector.z > -double.MAX_FINITE && minimum._vector.z < double.MAX_FINITE;

    double get north => maximum.latitude;
    double get south => minimum.latitude;
    double get east => maximum.longitude;
    double get west => minimum.longitude;

    void unionWith(CartographicBbox bbox) {
        minimum.minWith(bbox.minimum);
        maximum.maxWith(bbox.maximum);
    }

    Vector3 get length => maximum._vector - minimum._vector;
}
