// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

typedef void SignalHandler<T>(T data);
typedef void SignalHandler0();



class SignalFunctions<T> {
    Signal<T> signal = new Signal<T>();
    SignalSubscription subscribe(SignalHandler<T> handler, {String name, bool once: false}) {
        return signal.subscribe(handler, name: name, once: once);
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

    SignalSubscription subscribe(SignalHandler<T> userHandler, {String name, bool once: false}) {
        var streamSubscription = _controller.stream.listen(null);
        var mySignalSubscription = new SignalSubscription(streamSubscription, name: name);

        var wrappingHandler = (_SignalData<T> data) {
            userHandler(data.data);
            if (once) {
                mySignalSubscription.streamSubscription.cancel();
            }
        };
        streamSubscription.onData(wrappingHandler);

        streamSubscription.onError((err) => throw new StateError("error in $name signal/event stream: $err"));

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


void signalTest() {
    void test1() {
        Completer<int> c1 = new Completer<int>();
        SignalFunctions<int> MyEvent = new SignalFunctions<int>();
        MyEvent.subscribe((ev) => c1.complete(ev));
        MyEvent.fire(17);
        c1.future.then((i) {
            assert(i == 17);
            log("pass");
        });
    }

    void test2() {
        Completer<int> c2a = new Completer<int>();
        Completer<int> c2b = new Completer<int>();
        Completer<int> c2c = new Completer<int>();
        Completer<int> c2d = new Completer<int>();
        SignalFunctions<int> MyEvent2 = new SignalFunctions<int>();
        MyEvent2.subscribe((ev) {
            if (ev == 1) c2a.complete(ev);
            if (ev == 2) c2b.complete(ev);
        });
        MyEvent2.subscribe((ev) {
            if (ev == 1) c2c.complete(ev);
            if (ev == 2) c2d.complete(ev);
        });
        MyEvent2.fire(1);
        MyEvent2.fire(2);
        Future.wait([c2a.future, c2b.future, c2c.future, c2d.future]).then((cs) {
            log("pass");
        });
    }

    void test3() {
        Completer<int> c = new Completer<int>();
        SignalFunctions<int> MyEvent3 = new SignalFunctions<int>();
        MyEvent3.subscribe((ev) {
            assert(ev == 3);
            assert(ev != 5);
            if (ev == 3) c.complete(3);
        }, once: true);
        MyEvent3.fire(3);
        MyEvent3.fire(5);
        c.future.then((cs) {
            assert(cs == 3);
            log("pass");
        });

        // TODO: we can't check that ev==5 is never called, since we have nothing to wait on for it...
    }

    test1();
    test2();
    test3();
}
