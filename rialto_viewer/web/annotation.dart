part of rialto.viewer;

class Annotation {
    AnnotationShape shape;
    Vector3 _point1;
    Vector3 _point2;

    Annotation(Vector3 point1, Vector3 point2) {
        _point1 = point1;
        _point2 = point2;

        _fixCorners();

        _makeShape();
    }

    void _makeShape() {
        shape = new AnnotationShape(Hub.root.gl, _point1, _point2);
    }

    void _fixCorners() {
        if (_point1.x > _point2.x) {
            var t = _point1.x;
            _point1.x = _point2.x;
            _point2.x = t;
        }
        if (_point1.y > _point2.y) {
            var t = _point1.y;
            _point1.y = _point2.y;
            _point2.y = t;
        }
        _point1.z = _point2.z = min(_point1.z, _point2.z);

        assert(_point1.x <= _point2.x);
        assert(_point1.y <= _point2.y);
        assert(_point1.z == _point2.z);
    }
}
