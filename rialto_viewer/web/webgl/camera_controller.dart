// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// taken from https://github.com/threeDart/three.dart/blob/master/lib/extras/controls/trackball_controls.dart

class CameraController implements IMode {
    Hub _hub;
    Camera _camera;
    Element _canvas;
    bool isRunning;

    static const NONE = -1;
    static const ROTATE = 0;
    static const ZOOM = 1;
    static const PAN = 2;
    static const TOUCH_ROTATE = 3;
    static const TOUCH_ZOOM_PAN = 4;

    int _state, _prevState;
    bool enabled;

    num rotateSpeed, zoomSpeed, panSpeed;
    bool noRotate, noZoom, noPan, noRoll;
    bool staticMoving;
    bool autoUpdate;

    num dynamicDampingFactor;
    num minDistance, maxDistance;
    List keys;
    Vector3 target;

    Vector3 _eye;

    Vector3 _rotateStart, _rotateEnd;
    Vector2 _zoomStart, _zoomEnd;
    double _touchZoomDistanceStart, _touchZoomDistanceEnd;
    Vector2 _panStart, _panEnd;
    Vector3 lastPosition;

    CameraController(Camera this._camera, CanvasElement this._canvas) {
        _hub = Hub.root;
        _hub.cameraController = this;
        isRunning = false;

        _hub.modeController.register(this, ModeData.MOVEMENT);

        _hub.eventRegistry.MouseMove.subscribe(_handleMouseMove);
        _hub.eventRegistry.MouseDown.subscribe(_handleMouseDown);
        _hub.eventRegistry.MouseUp.subscribe(_handleMouseUp);
        _hub.eventRegistry.MouseWheel.subscribe(_handleMouseWheel);
        _hub.eventRegistry.KeyDown.subscribe(_handleKeyDown);
        _hub.eventRegistry.KeyUp.subscribe(_handleKeyUp);

        _hub.eventRegistry.MoveCameraHome.subscribe0(_handleMoveCameraHome);

        // API

        enabled = true;

        rotateSpeed = 1.0;
        zoomSpeed = 1.2;
        panSpeed = 0.3;

        noRotate = false;
        noZoom = false;
        noPan = false;
        noRoll = false;

        staticMoving = false;
        autoUpdate = false;
        dynamicDampingFactor = 0.2;

        minDistance = 0;
        maxDistance = double.INFINITY;

        keys = [65 /*A*/, 83 /*S*/, 68 /*D*/ ];

        // internals

        target = new Vector3.zero();

        lastPosition = new Vector3.zero();

        _state = NONE;
        _prevState = NONE;

        _eye = new Vector3.zero();

        _rotateStart = new Vector3.zero();
        _rotateEnd = new Vector3.zero();

        _zoomStart = new Vector2.zero();
        _zoomEnd = new Vector2.zero();

        _touchZoomDistanceStart = 0.0;
        _touchZoomDistanceEnd = 0.0;

        _panStart = new Vector2.zero();
        _panEnd = new Vector2.zero();
    }

    void startMode() {
    }

    void endMode() {
    }

    void _handleMouseUp(ev) {
        if (!isRunning) return;

        if (!enabled) {
            return;
        }

        _state = NONE;
    }

    void _handleMouseDown(MouseData event) {
        if (!isRunning) return;

        if (!enabled) {
            return;
        }

        if (_state == NONE) {
            _state = event.button;
        }

        if (_state == ROTATE && !noRotate) {
            _rotateStart = getMouseProjectionOnBall(event.x, event.y);
            _rotateEnd.setFrom(_rotateStart);
        } else if (_state == ZOOM && !noZoom) {
            _zoomStart = getMouseOnScreen(event.x, event.y);
            _zoomEnd.setFrom(_zoomStart);
        } else if (_state == PAN && !noPan) {
            _panStart = getMouseOnScreen(event.x, event.y);
            _panEnd.setFrom(_panStart);
        }
    }

    void _handleMouseWheel(WheelData event) {
        if (!isRunning) return;

        if (!enabled) {
            return;
        }

        _zoomStart.y += (1 / event.delta) * 0.05;

        update();
    }

    void _handleMouseMove(MouseData event) {
        if (!isRunning) return;

        if (!enabled) {
            return;
        }

        if (_state == ROTATE && !noRotate) {
            _rotateEnd = getMouseProjectionOnBall(event.x, event.y);
        } else if (_state == ZOOM && !noZoom) {
            _zoomEnd = getMouseOnScreen(event.x, event.y);
        } else if (_state == PAN && !noPan) {
            _panEnd = getMouseOnScreen(event.x, event.y);
        }

        update();
    }

    void _handleKeyDown(KeyboardData event) {
        if (!isRunning) return;

        if (!enabled) return;

        _prevState = _state;

        if (_state != NONE) {
            return;
        } else if (event.keyCode == keys[ROTATE] && !noRotate) {
            _state = ROTATE;
        } else if (event.keyCode == keys[ZOOM] && !noZoom) {
            _state = ZOOM;
        } else if (event.keyCode == keys[PAN] && !noPan) {
            _state = PAN;
        }
    }

    void _handleKeyUp(KeyboardData ev) {
        if (!isRunning) return;

        if (!enabled) {
            return;
        }

        _state = _prevState;
    }

    void _handleMoveCameraHome() {
    }


    Point get2DCoords(int mx, int my) {
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
        final int x = mx - left;
        final int y = _hub.height - (my - top);
        return new Point(x, y);
    }

    getMouseOnScreen(clientX, clientY) {
        Point p = get2DCoords(clientX, clientY);
        return new Vector2(p.x / _hub.width, p.y / _hub.height);
    }

    getMouseProjectionOnBall(clientX, clientY) {

        // [-1..+1]
        Vector2 p = getMouseOnScreen(clientX, clientY); // [0..1]
        p.x = p.x * 2.0 - 1.0;
        p.y = p.y * 2.0 - 1.0;
        var mouseOnBall = new Vector3(p.x, p.y, 0.0);

        var length = mouseOnBall.length;

        if (noRoll) {

            if (length < SQRT1_2) {

                mouseOnBall.z = sqrt(1.0 - length * length);

            } else {

                mouseOnBall.z = 0.5 / length;

            }

        } else if (length > 1.0) {

            mouseOnBall.normalize();

        } else {

            mouseOnBall.z = sqrt(1.0 - length * length);

        }

        _eye.setFrom(_camera.eye).sub(target);

        Vector3 projection = _camera.up.clone().normalize().scale(mouseOnBall.y);
        projection.add(_camera.up.cross(_eye).normalize().scale(mouseOnBall.x));
        projection.add(_eye.normalize().scale(mouseOnBall.z));

        return projection;

    }

    rotateCamera() {

        var angle = acos(_rotateStart.dot(_rotateEnd) / _rotateStart.length / _rotateEnd.length);

        if (!angle.isNaN && angle != 0) {

            Vector3 axis = _rotateStart.cross(_rotateEnd).normalize();
            Quaternion quaternion = new Quaternion.identity();

            angle *= rotateSpeed;

            quaternion.setAxisAngle(axis, angle);

            quaternion.rotate(_eye);
            quaternion.rotate(_camera.up);

            quaternion.rotate(_rotateEnd);

            if (staticMoving) {

                _rotateStart.setFrom(_rotateEnd);

            } else {

                quaternion.setAxisAngle(axis, -angle * (dynamicDampingFactor - 1.0));
                quaternion.rotate(_rotateStart);

            }

        }

    }

    zoomCamera() {

        if (_state == TOUCH_ZOOM_PAN) {

            var factor = _touchZoomDistanceStart / _touchZoomDistanceEnd;

            _touchZoomDistanceStart = _touchZoomDistanceEnd;

            _eye.scale(factor);

        } else {

            var factor = 1.0 + (_zoomEnd.y - _zoomStart.y) * zoomSpeed;

            if (factor != 1.0 && factor > 0.0) {

                _eye.scale(factor);

                if (staticMoving) {

                    _zoomStart.setFrom(_zoomEnd);

                } else {

                    _zoomStart.y += (_zoomEnd.y - _zoomStart.y) * this.dynamicDampingFactor;

                }

            }

        }

    }

    panCamera() {

        Vector2 mouseChange = _panEnd - _panStart;

        if (mouseChange.length != 0.0) {

            mouseChange.scale(_eye.length * panSpeed);

            Vector3 pan = _eye.cross(_camera.up).normalize().scale(mouseChange.x);
            pan += _camera.up.clone().normalize().scale(mouseChange.y);

            _camera.eye.add(pan);
            target.add(pan);

            if (staticMoving) {

                _panStart.setFrom(_panEnd);

            } else {

                _panStart += (_panEnd - _panStart).scale(dynamicDampingFactor);

            }

        }

    }

    checkDistances() {

        if (!noZoom || !noPan) {

            if (_camera.eye.length2 > maxDistance * maxDistance) {

                _camera.eye.normalize().scale(maxDistance);

            }

            if (_eye.length2 < minDistance * minDistance) {

                _camera.eye = target + _eye.normalize().scale(minDistance);

            }

        }

    }


    update() {

        _eye.setFrom(_camera.eye).sub(target);

        if (!noRotate) {
            rotateCamera();
        }

        if (!noZoom) {
            zoomCamera();
        }

        if (!noPan) {
            panCamera();
        }

        _camera.eye = target + _eye;

        checkDistances();

        _camera.target = target;

        // distanceToSquared
        if ((lastPosition - _camera.eye).length2 > 0.0) {
            lastPosition.setFrom(_camera.eye);
        }

    }
}
