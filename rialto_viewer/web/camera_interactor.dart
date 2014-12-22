part of rialto.viewer;


class CameraInteractor {
    Hub _hub;
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
    bool _altKeyDown;

    static const double MOTION_FACTOR = 10.0;


    CameraInteractor(Camera this._camera, CanvasElement this._canvas, Picker this._picker) {
        _hub = Hub.root;

        _hub.eventRegistry.MouseMove.subscribe(_handleMouseMove);
        _hub.eventRegistry.MouseDown.subscribe(_handleMouseDown);
        _hub.eventRegistry.MouseUp.subscribe(_handleMouseUp);
        _hub.eventRegistry.KeyDown.subscribe(_handleKeyDown);
        _hub.eventRegistry.KeyUp.subscribe(_handleKeyUp);
    }

    Point _get2DCoords(MouseData ev) {
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
        final int x = ev.x - left;
        final int y = _hub.height - (ev.y - top);
        return new Point(x, y);
    }

    void _handleMouseUp(ev) {
        _isMoving = false;
    }

    void _handleMouseDown(MouseData ev) {
        _isMoving = true;
        _currentX = ev.x;
        _currentY = ev.y;
        _button = ev.button;
        _dollyStep = max3(_camera.position.x, _camera.position.y, _camera.position.z) / 100.0;

        if (_picker != null && isPickingEnabled) {
            Point coords = _get2DCoords(ev);
            _picker.find(coords);
        }
    }

    void _handleMouseMove(MouseData ev) {
        _lastX = _currentX;
        _lastY = _currentY;
        _currentX = ev.x;
        _currentY = ev.y;

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

    void _handleKeyDown(KeyboardData ev) {
        var c = _camera;

        _altKeyDown = ev.altKey;

        switch (ev.keyCode) {
            case KeyboardData.KEY_UP:
                c.changeElevation(10.0);
                break;
            case KeyboardData.KEY_DOWN:
                c.changeElevation(-10.0);
                break;
            case KeyboardData.KEY_LEFT:
                c.changeAzimuth(-10.0);
                break;
            case KeyboardData.KEY_RIGHT:
                c.changeAzimuth(10.0);
                break;
            case KeyboardData.KEY_W:
                c.changeFovy(10.0);
                break;
            case KeyboardData.KEY_N:
                c.changeFovy(-10.0);
                break;
        }
    }

    void _handleKeyUp(KeyboardData ev) {
        _altKeyDown = !ev.altKey;
    }

    void dolly(double value) {
        if (value > 0) {
            _dollyLoc += _dollyStep;
        } else {
            _dollyLoc -= _dollyStep;
        }
        _camera.dolly(_dollyLoc);
    }

    void rotate(double dx, double dy) {
        final double delta_elevation = -20.0 / _hub.height;
        final double delta_azimuth = -20.0 / _hub.width;

        final double nAzimuth = dx * delta_azimuth * MOTION_FACTOR;
        final double nElevation = dy * delta_elevation * MOTION_FACTOR;

        _camera.changeAzimuth(nAzimuth);
        _camera.changeElevation(nElevation);
    }
}

