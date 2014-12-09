// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


typedef void Handler<T>(T data);

class Signal<T> {
    Stream<T> _onEvent;
    StreamController<T> _controller;
    Map<Handler, StreamSubscription> _map = new Map<Handler, StreamSubscription>();

    Signal() {
        _controller = new StreamController.broadcast();
        _onEvent = _controller.stream;
    }

    void subscribe(Handler handler) {
        var subscription = _onEvent.listen(handler);
        _map[handler] = subscription;
    }

    void unsubscribe(Handler handler) {
        if (_map.containsKey(handler)) {
            var subscription = _map.remove(handler);
            subscription.cancel();
        }
    }

    void fire(T t) {
        _controller.add(t);
    }
}