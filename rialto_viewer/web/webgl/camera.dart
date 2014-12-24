// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class Camera {
    Matrix4 _viewMatrix = new Matrix4.zero();
    Matrix4 _perspective = new Matrix4.zero();
    Vector3 up = new Vector3(0.0, 1.0, 0.0);
    Vector3 _eye = new Vector3.zero();
    Vector3 _defaultEye = new Vector3.zero();
    Vector3 _target = new Vector3.zero();
    Vector3 _defaultTarget = new Vector3.zero();
    double _fovy = 45.0;

    Camera();

    // https://github.com/greggman/webgl-fundamentals/
    // http://mikeheavers.com/main/code-item/webgl_circular_camera_rotation_around_a_single_axis_in_threejs

    Matrix4 getViewMatrix() {
        var m = GlMath.makeTranslationMatrix(_eye.x, _eye.y, _eye.z);
        Vector3 myeye = GlMath.getTranslationVector(m);
        var cameraMatrix = GlMath.makeLookAtMatrix(myeye, _target, up);
        var viewMatrix = cameraMatrix.clone();
        viewMatrix.invert();
        return viewMatrix;
    }

    Matrix4 getPerspectiveMatrix(double aspect) {
        _perspective = GlMath.makePerspectiveMatrix(degToRad(fovy), aspect, 0.1, 100000.0);
        //_perspective = GlMath.makeOrthographicMatrix(-10000, 10000, -10000, 10000, -10000, 10000);
        return _perspective;
    }

    void goHome() {
        eye = defaultEye;
        target = defaultTarget;
        _fovy = 65.0;
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

    double get fovy => _fovy;
    void set fovy(double degrees) {
        _fovy = clamp(degrees, 20.0, 160.0);
    }
}
