// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

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

    Matrix4 _viewMatrix = new Matrix4.zero();
    Matrix4 _perspective = new Matrix4.zero();
    Vector3 _up = new Vector3.zero();
    Vector3 _right = new Vector3.zero();
    Vector3 _normal = new Vector3.zero();
    Vector3 _eye = new Vector3.zero();
    Vector3 _defaultEye = new Vector3.zero();
    Vector3 _target = new Vector3.zero();
    Vector3 _defaultTarget = new Vector3.zero();
    double _azimuth = 0.0;
    double _elevation = 0.0;
    int _cameraType = ORBITING;
    double _fovy = 65.0;
    double _zoom = 0.0;

    Camera(int cameraType) : _cameraType = cameraType;

    Matrix4 getPerspectiveMatrix(double aspect) {
        return makePerspectiveMatrix(degToRad(fovy), aspect, 0.001, 10000.0);
    }

    void goHome() {
        eye = defaultEye;
        target = defaultTarget;
        _right = _xAxis;
        _up = _yAxis;
        _normal = _zAxis;
        _azimuth = 0.0;
        _elevation = 0.0;
    }

    Vector3 get eye => _eye;
    void set eye(Vector3 v) {
        v.copyInto(_eye);
    }

    Vector3 get defaultEye => _defaultEye;
    void set defaultEye(Vector3 v) {
        v.copyInto(_defaultEye);
    }

    Vector3 get target => _target;
    void set target(Vector3 v) {
        v.copyInto(_target);
    }

    Vector3 get defaultTarget => _defaultTarget;
    void set defaultTarget(Vector3 v) {
        v.copyInto(_defaultTarget);
    }

    double get zoom => _zoom;
    void set zoom(double amt) {
        _zoom = amt;
        _dolly();
    }

    void _dolly() {
        var p = new Vector3.copy(eye);

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

        eye = newPosition;
        //update();
    }

    double get fovy => _fovy;
    void set fovy(double degrees) {
        _fovy = clamp(degrees, 20.0, 160.0);
        //print("Fovy: $_fovy");
        //update();
    }

    double get azimuth => _azimuth;
    void set azimuth(double degrees) {
        _azimuth = clamp(degrees, -90.0, 90.0);
        //print("Azimuth: $_azimuth");
        //update();
    }

    double get elevation => _elevation;
    void set elevation(degrees) {
        _elevation = clamp(degrees, -90.0, 90.0);
        //print("Elevation: $_elevation");
        //update();
    }

    void _calculateOrientation() {
        _right = _viewMatrix * _xAxis;
        _up = _viewMatrix * _yAxis;
        _normal = _viewMatrix * _zAxis;
    }

    void update() {
        _viewMatrix.setIdentity();

        _calculateOrientation();

        switch (_cameraType) {
            case TRACKING:
                _viewMatrix.translate(eye);
                _viewMatrix.rotateY(degToRad(azimuth));
                _viewMatrix.rotateX(degToRad(elevation));
                break;
            case ORBITING:
                _viewMatrix.rotateY(degToRad(azimuth));
                _viewMatrix.rotateX(degToRad(elevation));
                _viewMatrix.translate(eye);
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
            eye = _viewMatrix * _zero;
        }

        var cameraPosition = new Vector3(_viewMatrix[12], _viewMatrix[13], _viewMatrix[14]);
        var cameraMatrix = makeViewMatrix(cameraPosition, target, _yAxis);
        cameraMatrix.copyInto(_viewMatrix);
        //_viewMatrix.invert();
    }

    Matrix4 getViewMatrix() {
        var m = new Matrix4.copy(_viewMatrix);
        //m.invert();
        return m;
    }
}
