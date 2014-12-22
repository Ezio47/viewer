part of rialto.viewer;


// when mouse button 1 is prerssedl: camera around center of image
// when mouse 1 is pressed and with the ALT key pressed: camera will dolly (move forward / zoom in)
//    according to how much the mouse is moved in the Y direction
//    BUG: X direction seems to have an effect also, hmmm
// the four firectional arrow keys moves the camera in orbit mode, just liek with the mouse button 1
// the W and N keys are used to widen and narrow the field of view (FoVY) - the range is restricted
//     to between 20 and 160 degrees
// the mouse wheel moves in (dollies) - NOT YET IMPLEMENTED
// NEED TO IMPLEMENT a switch between tracking and orbital modes
// NEED TO IMPLEMENT a 'home' button

enum CameraType {
    Orbiting,
    Tracking
}

class Camera {

    final Vector3 xAxis = new Vector3(1.0, 0.0, 0.0);
    final Vector3 yAxis = new Vector3(0.0, 1.0, 0.0);
    final Vector3 zAxis = new Vector3(0.0, 0.0, 1.0);

    Matrix4 matrix = new Matrix4.zero();
    Vector3 up = new Vector3.zero();
    Vector3 right = new Vector3.zero();
    Vector3 normal = new Vector3.zero();
    Vector3 position = new Vector3.zero();
    Vector3 focus = new Vector3.zero();
    Vector3 home = new Vector3.zero();
    double azimuth = 0.0;
    double elevation = 0.0;
    CameraType cameraType = CameraType.Orbiting;
    double steps = 0.0;
    double fovy = 65.0;

    Camera(CameraType this.cameraType) { }

    void goHome(Vector3 h) {
        if (h != null) {
            home = h;
        }
        setPosition(home);
        setAzimuth(0.0);
        setElevation(0.0);
        steps = 0.0;
    }

    void dolly(double s) {
        var p = new Vector3.copy(position);

        var n = new Vector3.zero();
        normal.normalizeInto(n);

        final double step = s - steps;

        var newPosition = new Vector3.zero();

        switch(cameraType) {
            case CameraType.Tracking:
                newPosition.x = p.x - step * n.x;
                newPosition.y = p.y - step * n.y;
                newPosition.z = p.z - step * n.z;
                break;
            case CameraType.Orbiting:
                newPosition.x = p.x;
                newPosition.y = p.y;
                newPosition.z = p.z - step;
                break;
            default:
               assert(false); // BUG
        }

        setPosition(newPosition);
        steps = s;
    }

    void setPosition(Vector3 p) {
        p.copyInto(position);
        update();
    }

    void setFocus(Vector3 f) {
        f.copyInto(focus);
        update();
    }

    void setFovy(double degrees) {
        fovy = clamp(degrees, 20.0, 160.0);
        print("Fovy: $fovy");
    }

    void changeFovy(double degrees) {
        setFovy(fovy + degrees);
    }

    void setAzimuth(double degrees) {
        changeAzimuth(degrees - azimuth);
    }

    void changeAzimuth(double degrees) {
        azimuth = clamp360(azimuth + degrees);
        update();
    }

    void setElevation(double degrees) {
        changeElevation(degrees - elevation);
    }

    void changeElevation(double degrees) {
        elevation = clamp360(elevation + degrees);
        update();
    }

    void _calculateOrientation() {
        right = matrix * xAxis;
        up = matrix * yAxis;
        normal = matrix * zAxis;
    }

    void update() {
        matrix.setIdentity();

        _calculateOrientation();

        switch (cameraType) {
            case CameraType.Tracking :
            matrix.translate(position);
            matrix.rotateY(degToRad(azimuth));
            matrix.rotateX(degToRad(elevation));
            break;
            case CameraType.Orbiting:
            matrix.rotateY(degToRad(azimuth));
        matrix.rotateX(degToRad(elevation));
            matrix.translate(position);
            //var trxLook = new Matrix4.zero();
            //mat4.lookAt(position, focus, up, trxLook);
            //mat4.inverse(trxLook);
            //mat4.multiply(matrix,trxLook);
            break;
            default:
                assert(false);
        }

        _calculateOrientation();

        if (cameraType == CameraType.Tracking) {
            position = matrix * new Vector3.zero();
        }
    }

    Matrix4 getViewTransform() {
        var m = new Matrix4.copy(matrix);
        m.invert();
        return m;
    }
}
