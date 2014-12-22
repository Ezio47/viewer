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
    bool _isMouseDown = false;
    bool isPickingEnabled = true;

    static const double MOTION_FACTOR = 10.0;


    CameraInteractor(Camera this._camera, CanvasElement this._canvas, Picker this._picker) {
        _hub = Hub.root;

        _hub.eventRegistry.MouseMove.subscribe(_handleMouseMove);
        _hub.eventRegistry.MouseDown.subscribe(_handleMouseDown);
        _hub.eventRegistry.MouseUp.subscribe(_handleMouseUp);
        _hub.eventRegistry.MouseWheel.subscribe(_handleMouseWheel);
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
        _isMouseDown = false;
    }

    void _handleMouseDown(MouseData ev) {
        _isMouseDown = true;
        _currentX = ev.x;
        _currentY = ev.y;
        _button = ev.button;
        _dollyStep = max3(_camera.position.x, _camera.position.y, _camera.position.z) / 100.0;

        if (_picker != null && isPickingEnabled) {
            Point coords = _get2DCoords(ev);
            _picker.find(coords);
        }
    }

    void _handleMouseWheel(WheelData ev) {
        double d = ( 1 / ev.delta ) * 0.05;
        _camera.zoom += d;
        //print("${ev.delta} ${_camera.zoom}");
    }

    void _handleMouseMove(MouseData ev) {
        _lastX = _currentX;
        _lastY = _currentY;
        _currentX = ev.x;
        _currentY = ev.y;

        if (!_isMouseDown) return;

        final bool alt = ev.altKey;
        final double dx = (_currentX - _lastX).toDouble();
        final double dy = (_currentY - _lastY).toDouble();

        if (_button == 0) {
            rotate(dx, dy);
        }
    }

    void _handleKeyDown(KeyboardData ev) {
        var c = _camera;

        switch (ev.keyCode) {
            case KeyboardData.KEY_UP:
                c.elevation += 10.0;
                break;
            case KeyboardData.KEY_DOWN:
                c.elevation += -10.0;
                break;
            case KeyboardData.KEY_LEFT:
                c.azimuth += -10.0;
                break;
            case KeyboardData.KEY_RIGHT:
                c.azimuth += 10.0;
                break;
            case KeyboardData.KEY_W:
                c.fovy += 10.0;
                break;
            case KeyboardData.KEY_N:
                c.fovy += -10.0;
                break;
        }
    }

    void _handleKeyUp(KeyboardData ev) {
    }

    void rotate(double dx, double dy) {
        final double delta_elevation = -20.0 / _hub.height;
        final double delta_azimuth = -20.0 / _hub.width;

        final double nAzimuth = dx * delta_azimuth * MOTION_FACTOR;
        final double nElevation = dy * delta_elevation * MOTION_FACTOR;

        _camera.azimuth += nAzimuth;
        _camera.elevation += nElevation;
    }
}

