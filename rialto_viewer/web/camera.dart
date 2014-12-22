part of rialto.viewer;


// when mouse button 1 is prerssed: camera around center of image
// when mouse 1 is pressed and with the ALT key pressed: camera will dolly (move forward / zoom in)
//    according to how much the mouse is moved in the Y direction
//    BUG: X direction seems to have an effect also, hmmm
// the four firectional arrow keys moves the camera in orbit mode, just liek with the mouse button 1
// the W and N keys are used to widen and narrow the field of view (FoVY) - the range is restricted
//     to between 20 and 160 degrees
// the mouse wheel moves in (dollies) - NOT YET IMPLEMENTED
// NEED TO IMPLEMENT a switch between tracking and orbital modes
// NEED TO IMPLEMENT a 'home' button


class Camera {
    static const ORBITING = 0;
    static const TRACKING = 1;

    final Vector3 _zero = new Vector3.zero();
    final Vector3 _xAxis = new Vector3(1.0, 0.0, 0.0);
    final Vector3 _yAxis = new Vector3(0.0, 1.0, 0.0);
    final Vector3 _zAxis = new Vector3(0.0, 0.0, 1.0);

    Matrix4 _matrix = new Matrix4.zero();
    Vector3 _up = new Vector3.zero();
    Vector3 _right = new Vector3.zero();
    Vector3 _normal = new Vector3.zero();
    Vector3 _position = new Vector3.zero();
    Vector3 _home = new Vector3.zero();
    double _azimuth = 0.0;
    double _elevation = 0.0;
    int _cameraType = ORBITING;
    double _fovy = 65.0;
    double _zoom = 0.0;

    Camera(int cameraType) : _cameraType = cameraType;

    void goHome(Vector3 h) {
        if (h != null) {
            _home = h;
        }
        position = _home;
        azimuth = 0.0;
        elevation = 0.0;
        _zoom = 0.0;
    }

    double get zoom => _zoom;
    void set zoom(double target) {
        _zoom = target;
        _dolly();
    }

    void _dolly() {
        var p = new Vector3.copy(position);

        var n = new Vector3.zero();
        _normal.normalizeInto(n);

        var newPosition = new Vector3.zero();

        switch (_cameraType) {
            case TRACKING:
                newPosition.x = p.x - _zoom * n.x;
                newPosition.y = p.y - _zoom * n.y;
                newPosition.z = p.z - _zoom * n.z;
                break;
            case ORBITING:
                newPosition.x = p.x;
                newPosition.y = p.y;
                newPosition.z = p.z - _zoom;
                break;
            default:
                assert(false); // BUG
        }

        position = newPosition;
        update();
    }

    Vector3 get position => _position;
    void set position(Vector3 p) {
        p.copyInto(position);
        update();
    }

    double get fovy => _fovy;
    void set fovy(double degrees) {
        _fovy = clamp(degrees, 20.0, 160.0);
        //print("Fovy: $_fovy");
        update();
    }

    double get azimuth => _azimuth;
    void set azimuth(double degrees) {
        _azimuth = clamp(degrees, -90.0, 90.0);
        //print("Azimuth: $_azimuth");
        update();
    }

    double get elevation => _elevation;
    void set elevation(degrees) {
        _elevation = clamp(degrees, -90.0, 90.0);
        //print("Elevation: $_elevation");
        update();
    }

    void _calculateOrientation() {
        _right = _matrix * _xAxis;
        _up = _matrix * _yAxis;
        _normal = _matrix * _zAxis;
    }

    void update() {
        _matrix.setIdentity();

        _calculateOrientation();

        switch (_cameraType) {
            case TRACKING:
                _matrix.translate(position);
                _matrix.rotateY(degToRad(azimuth));
                _matrix.rotateX(degToRad(elevation));
                break;
            case ORBITING:
                _matrix.rotateY(degToRad(azimuth));
                _matrix.rotateX(degToRad(elevation));
                _matrix.translate(position);
                //var trxLook = new Matrix4.zero();
                //mat4.lookAt(position, focus, up, trxLook);
                //mat4.inverse(trxLook);
                //mat4.multiply(matrix,trxLook);
                break;
            default:
                assert(false);
        }

        _calculateOrientation();

        if (_cameraType == TRACKING) {
            position = _matrix * _zero;
        }
    }

    Matrix4 getViewTransform() {
        var m = new Matrix4.copy(_matrix);
        m.invert();
        return m;
    }
}
