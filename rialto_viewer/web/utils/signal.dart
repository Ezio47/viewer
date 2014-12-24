// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

typedef void SignalHandler<T>(T data);
typedef void SignalHandler0();



class SignalFunctions<T> {
    Signal<T> signal = new Signal<T>();
    SignalSubscription subscribe(SignalHandler<T> handler) {
        return signal.subscribe(handler);
    }
    void unsubscribe(SignalSubscription s) => signal.unsubscribe(s);
    void fire(T data) => signal.fire(data);

    // these two hacks allow for type-checking of 0-arity signal data payloads
    SignalSubscription subscribe0(SignalHandler0 handler0) {
        return signal.subscribe((_) => handler0());
    }
    void fire0() => signal.fire(null);

    SignalFunctions();
}


class _SignalData<T> {
    T data;
    _SignalData(this.data);
}

class SignalSubscription {
    String _name;
    StreamSubscription _streamSubscription;

    SignalSubscription(StreamSubscription subscription, {String name})
            : _streamSubscription = subscription,
              _name = name;

    StreamSubscription get streamSubscription => _streamSubscription;
    String get name => _name;
}


class Signal<T> {
    String _name;
    StreamController<_SignalData<T>> _controller;

    Signal({String name}) {
        _name = name;
        _controller = new StreamController.broadcast();
    }

    String get name => _name;

    SignalSubscription subscribe(SignalHandler<T> userHandler, {String name}) {
        var streamSubscription = _controller.stream.listen(null);
        var mySignalSubscription = new SignalSubscription(streamSubscription, name: name);

        var wrappingHandler = (_SignalData<T> data) {
                userHandler(data.data);
        };

        streamSubscription.onData(wrappingHandler);
        streamSubscription.onError((err) => print("Error on $name: $err")); // BUG
        ////streamSubscription.onDone(() => print("Done on $name"));
        return mySignalSubscription;
    }

    void unsubscribe(SignalSubscription signalSubscription) {
        signalSubscription.streamSubscription.cancel();
    }

    void fire(T t) {
        var data = new _SignalData<T>(t);
        _controller.add(data);
    }

    Future close() => _controller.close();
}
