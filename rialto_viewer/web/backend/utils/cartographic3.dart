// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


/// A point, represented by longitude, latitude, and height (in meters).
class Cartographic3 {
    Vector3 _vector = new Vector3(0.0, 0.0, 0.0);

    Cartographic3(double longitude, double latitude, double height) {
        this.longitude = longitude;
        this.latitude = latitude;
        this.height = height;
    }

    Cartographic3.zero();

    Cartographic3.copy(Cartographic3 c) : this(c.longitude, c.latitude, c.height);

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

    void minWith3(double x, double y, double z) => Utils.vectorMinWith3(_vector, x, y, z);
}


/// A bounding box in cartographic (lat/lon) space.
class CartographicBbox {
    Cartographic3 minimum;
    Cartographic3 maximum;

    CartographicBbox(Cartographic3 this.minimum, Cartographic3 this.maximum);

    CartographicBbox.empty() {
        minimum = new Cartographic3.asMax();
        maximum = new Cartographic3.asMin();
    }

    CartographicBbox.copy(CartographicBbox box) {
        minimum = new Cartographic3.copy(box.minimum);
        maximum = new Cartographic3.copy(box.maximum);
    }

    CartographicBbox.fromValues(double minx, double miny, double minz, double maxx, double maxy, double maxz) {
        minimum = new Cartographic3(minx, miny, minz);
        maximum = new Cartographic3(maxx, maxy, maxz);
    }

    bool get isValid =>
            (minimum._vector.x > -double.MAX_FINITE && minimum._vector.x < double.MAX_FINITE) &&
                    (minimum._vector.y > -double.MAX_FINITE && minimum._vector.y < double.MAX_FINITE) &&
                    (minimum._vector.z > -double.MAX_FINITE && minimum._vector.z < double.MAX_FINITE);

    double get north => maximum.latitude;
    double get south => minimum.latitude;
    double get east => maximum.longitude;
    double get west => minimum.longitude;

    void unionWith(CartographicBbox bbox) {
        if (bbox == null) return;

        minimum.minWith(bbox.minimum);
        maximum.maxWith(bbox.maximum);
    }

    void unionWith3(double x, double y, double z) {
        Utils.vectorMinWith3(minimum._vector, x, y, z);
        Utils.vectorMaxWith3(maximum._vector, x, y, z);
    }

    Vector3 get length => maximum._vector - minimum._vector;

    String toString() {
        String s =
                "min=${Utils.toString_Vector3(minimum._vector)} " +
                "max=${Utils.toString_Vector3(maximum._vector)} " +
                "len=${Utils.toString_Vector3(length)}";
        return s;
    }
}
