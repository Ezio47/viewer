part of rialto.viewer;

const bool GREGGMAN = true;

class GlMath {
    static Matrix4 makeOrthographicMatrix(num left, num right, num bottom, num top, num near, num far) {
        left = left.toDouble();
        right = right.toDouble();
        bottom = bottom.toDouble();
        top = top.toDouble();
        near = near.toDouble();
        far = far.toDouble();
        double rml = right - left;
        double rpl = right + left;
        double tmb = top - bottom;
        double tpb = top + bottom;
        double fmn = far - near;
        double fpn = far + near;
        Matrix4 r = new Matrix4.zero();
        r.setEntry(0, 0, 2.0 / rml);
        r.setEntry(1, 1, 2.0 / tmb);
        r.setEntry(2, 2, -2.0 / fmn);
        r.setEntry(0, 3, -rpl / rml);
        r.setEntry(1, 3, -tpb / tmb);
        r.setEntry(2, 3, -fpn / fmn);
        r.setEntry(3, 3, 1.0);
        return r;
    }

    static Matrix4 makePerspectiveMatrix(double fieldOfViewInRadians, double aspect, double near, double far) {
        var m = new Matrix4.zero();
        if (GREGGMAN) {
            var f = tan(PI * 0.5 - 0.5 * fieldOfViewInRadians);
            var rangeInv = 1.0 / (near - far);
            m[0] = f / aspect;
            m[5] = f;
            m[10] = (near + far) * rangeInv;
            m[11] = -1.0;
            m[14] = near * far * rangeInv * 2.0;
        } else {
            setPerspectiveMatrix(m, fieldOfViewInRadians, aspect, near, far);
        }
        return m;
    }

    static Vector3 getTranslationVector(Matrix4 m) {
        var v = m.getTranslation();
        return v;
    }

    static Matrix4 makeTranslationMatrix(double tx, double ty, double tz) {
        var m = new Matrix4.identity();
        m[12] = tx;
        m[13] = ty;
        m[14] = tz;
        return m;
    }

    static Matrix4 makeScaleMatrix(double sx, double sy, double sz) {
        var m = new Matrix4.zero();
        m[0] = sx;
        m[5] = sy;
        m[10] = sz;
        m[15] = 1.0;
        return m;
    }

    static Matrix4 makeXRotationMatrix(angleInRadians) {
        var c = cos(angleInRadians);
        var s = sin(angleInRadians);
        var m = new Matrix4.identity();
        m[5] = c;
        m[6] = s;
        m[9] = -s;
        m[10] = c;
        return m;
    }

    static Matrix4 makeYRotationMatrix(angleInRadians) {
        var c = cos(angleInRadians);
        var s = sin(angleInRadians);
        var m = new Matrix4.identity();
        m[0] = c;
        m[2] = -s;
        m[8] = s;
        m[10] = c;
        return m;
    }

    static Matrix4 makeZRotationMatrix(angleInRadians) {
        var c = cos(angleInRadians);
        var s = sin(angleInRadians);
        var m = new Matrix4.identity();
        m[0] = c;
        m[1] = s;
        m[4] = -s;
        m[5] = c;
        return m;
    }

    static Matrix4 makeLookAtMatrix(Vector3 cameraPosition, Vector3 cameraFocusPosition, Vector3 upDirection) {
        Vector3 z = cameraPosition - cameraFocusPosition;
        z.normalize();
        Vector3 x = upDirection.cross(z);
        x.normalize();
        Vector3 y = z.cross(x);
        y.normalize();

        Matrix4 viewMatrix = new Matrix4.zero();
        viewMatrix.setEntry(0, 0, x.x);
        viewMatrix.setEntry(1, 0, x.y);
        viewMatrix.setEntry(2, 0, x.z);
        viewMatrix.setEntry(0, 1, y.x);
        viewMatrix.setEntry(1, 1, y.y);
        viewMatrix.setEntry(2, 1, y.z);
        viewMatrix.setEntry(0, 2, z.x);
        viewMatrix.setEntry(1, 2, z.y);
        viewMatrix.setEntry(2, 2, z.z);
        viewMatrix.setEntry(0, 3, cameraPosition.x);
        viewMatrix.setEntry(1, 3, cameraPosition.y);
        viewMatrix.setEntry(2, 3, cameraPosition.z);
        viewMatrix.setEntry(3, 3, 1.0);
        return viewMatrix;
    }
}
