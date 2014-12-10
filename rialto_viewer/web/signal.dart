// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


typedef void Handler0();
typedef void HandlerT<T>(T data);

class Signal0 {
    Stream _onEvent;
    StreamController _controller;

    Signal0() {
        _controller = new StreamController.broadcast();
        _onEvent = _controller.stream;
    }

    StreamSubscription subscribe(Handler0 handler) {
        assert(_onEvent != null);
        var subscription = _onEvent.listen((_) => handler());
        return subscription;
    }

    void unsubscribe(StreamSubscription subscription) {
        subscription.cancel();
    }

    void fire() {
        _controller.add(null);
    }
}

class SignalT<T> {
    Stream<T> _onEvent;
    StreamController<T> _controller;

    SignalT() {
        _controller = new StreamController.broadcast();
        _onEvent = _controller.stream;
    }

    StreamSubscription subscribe(HandlerT handler) {
        var subscription = _onEvent.listen(handler);
        return subscription;
    }

    void unsubscribe(StreamSubscription subscription) {
        subscription.cancel();
    }

    void fire(T t) {
        _controller.add(t);
    }
}

class SignalFunctions0 {
    Signal0 signal = new Signal0();
    StreamSubscription subscribe(Handler0 handler)  { return signal.subscribe(handler); }
    void unsubscribe(StreamSubscription s) => signal.unsubscribe(s);
    void fire() => signal.fire();
    SignalFunctions0();
}

class SignalFunctionsT<T> {
    SignalT<T> signal = new SignalT<T>();
    StreamSubscription subscribe(HandlerT<T> handler) { return signal.subscribe(handler); }
    void unsubscribe(StreamSubscription s) => signal.unsubscribe(s);
    void fire(T data) => signal.fire(data);
    SignalFunctionsT();
}
