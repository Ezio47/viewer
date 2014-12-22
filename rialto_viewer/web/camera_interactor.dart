part of rialto.viewer;


enum KeyCode {
    UP,
    DOWN,
    RIGHT,
    LEFT,
    W,
    N
}
const int KEY_UP = 38;
const int KEY_DOWN = 40;
const int KEY_RIGHT = 39;
const int KEY_LEFT = 37;
const int KEY_W = 87;
const int KEY_N = 78;

class CameraInteractor {

    Camera _camera;
    Element _canvas;
    Picker _picker = null;
    double _dollyLoc = 0.0;
    double _dollyStep = 0.0;
    int _currentX = 0;
    int _currentY = 0;
    int _lastX = 0;
    int _lastY = 0;
    int _button = 0;
    bool _isMoving = false;
    bool isPickingEnabled = true;

    static const double MOTION_FACTOR = 10.0;


    CameraInteractor(Camera this._camera, CanvasElement this._canvas, Picker this._picker) {
        _canvas.onMouseDown.listen(_onMouseDown);
        _canvas.onMouseUp.listen(_onMouseUp);
        _canvas.onMouseMove.listen(_onMouseMove);
        window.onKeyDown.listen(_onKeyDown);
        window.onKeyUp.listen(_onKeyUp);
    }

    Vector2i _get2DCoords(ev) {
        int top = 0;
        int left = 0;
        Element obj = _canvas;

        while (obj != null && obj.tagName != 'BODY') {
            top += obj.offsetTop;
            left += obj.offsetLeft;
            obj = obj.offsetParent;
        }

        left += window.pageXOffset;
        top -= window.pageYOffset;

        // return relative mouse position
        final int x = ev.clientX - left;
        final int y = c_height - (ev.clientY - top);
        return new Vector2i(x, y);
    }

    void _onMouseUp(ev) {
        _isMoving = false;
    }

    void _onMouseDown(ev) {
        _isMoving = true;
        _currentX = ev.clientX;
        _currentY = ev.clientY;
        _button = ev.button;
        _dollyStep = max3(_camera.position.x, _camera.position.y, _camera.position.z) / 100.0;

        if (_picker != null && isPickingEnabled) {
            Vector2i coords = _get2DCoords(ev);
            _picker.find(coords);
        }
    }

    void _onMouseMove(ev) {
        _lastX = _currentX;
        _lastY = _currentY;
        _currentX = ev.clientX;
        _currentY = ev.clientY;

        if (!_isMoving) return;

        final bool alt = ev.altKey;
        final double dx = (_currentX - _lastX).toDouble();
        final double dy = (_currentY - _lastY).toDouble();

        if (_button == 0) {
            if (alt) {
                dolly(dy);
            } else {
                rotate(dx, dy);
            }
        }
    }

    void _onKeyDown(ev) {
        var c = _camera;

        switch (ev.keyCode) {
            case KEY_UP:
                c.changeElevation(10.0);
                break;
            case KEY_DOWN:
                c.changeElevation(-10.0);
                break;
            case KEY_LEFT:
                c.changeAzimuth(-10.0);
                break;
            case KEY_RIGHT:
                c.changeAzimuth(10.0);
                break;
            case KEY_W:
                c.changeFovy(10.0);
                break;
            case KEY_N:
                c.changeFovy(-10.0);
                break;
        }
    }

    void _onKeyUp(ev) {}

    void dolly(double value) {
        if (value > 0) {
            _dollyLoc += _dollyStep;
        } else {
            _dollyLoc -= _dollyStep;
        }
        _camera.dolly(_dollyLoc);
    }

    void rotate(double dx, double dy) {
        final double delta_elevation = -20.0 / c_height;
        final double delta_azimuth = -20.0 / c_width;

        final double nAzimuth = dx * delta_azimuth * MOTION_FACTOR;
        final double nElevation = dy * delta_elevation * MOTION_FACTOR;

        _camera.changeAzimuth(nAzimuth);
        _camera.changeElevation(nElevation);
    }
}

