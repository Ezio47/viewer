// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


typedef void Handler0();
typedef void HandlerT<T>(T data);

class Signal0 {
    Stream _onEvent;
    StreamController _controller;
    Map<Handler0, StreamSubscription> _map = new Map<Handler0, StreamSubscription>();

    Signal0() {
        _controller = new StreamController.broadcast();
        _onEvent = _controller.stream;
    }

    void subscribe(Handler0 handler) {
        assert(_onEvent != null);
        var subscription = _onEvent.listen((_) => handler());
        _map[handler] = subscription;
    }

    void unsubscribe(Handler0 handler) {
        if (_map.containsKey(handler)) {
            var subscription = _map.remove(handler);
            subscription.cancel();
        }
    }

    void fire() {
        _controller.add(null);
    }
}

class SignalT<T> {
    Stream<T> _onEvent;
    StreamController<T> _controller;
    Map<HandlerT, StreamSubscription> _map = new Map<HandlerT, StreamSubscription>();

    SignalT() {
        _controller = new StreamController.broadcast();
        _onEvent = _controller.stream;
    }

    void subscribe(HandlerT handler) {
        var subscription = _onEvent.listen(handler);
        _map[handler] = subscription;
    }

    void unsubscribe(HandlerT handler) {
        if (_map.containsKey(handler)) {
            var subscription = _map.remove(handler);
            subscription.cancel();
        }
    }

    void fire(T t) {
        _controller.add(t);
    }
}

class SignalFunctions0 {
    Signal0 signal = new Signal0();
    void subscribe(Handler0 handler) => signal.subscribe(handler);
    void unsubscribe(Handler0 handler) => signal.unsubscribe(handler);
    void fire() => signal.fire();
    SignalFunctions0();
}

class SignalFunctionsT<T> {
    SignalT<T> signal = new SignalT<T>();
    void subscribe(HandlerT<T> handler) => signal.subscribe(handler);
    void unsubscribe(HandlerT<T> handler) => signal.unsubscribe(handler);
    void fire(T data) => signal.fire(data);
    SignalFunctionsT();
}
