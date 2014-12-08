part of rialto.viewer;


typedef void Handler<T>(T data);

class Signal<T> {
    Stream<T> _onEvent;
    StreamController<T> _controller;

    Signal() {
        _controller = new StreamController<T>();
        _onEvent = _controller.stream;
    }

    void listen(Handler<T> handler) {
        _onEvent.listen(handler);
    }

    void fire(T t) {
        _controller.add(t);
    }
}


class _MouseEvent {
    int x,y;
    _MouseEvent(this.x, this.y);
}

_Dispatcher dispatcher;
class _Dispatcher {
    Signal<_MouseEvent> mouseEvent;
    _Dispatcher();
}

class _UI {
    _UI() {
        window.onMouseMove.listen(systemhandler);
    }
    systemhandler(var event) {
        dispatcher.mouseEvent.fire(new _MouseEvent(event.x, event.y));
    }
}

class _Camera {
    _Camera() {
        dispatcher.mouseEvent.listen(handler);
    }

    void handler(MouseEvent me) {
    }
}
