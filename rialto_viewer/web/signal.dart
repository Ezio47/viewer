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


// at the time that the signal is fired, we want to be able to control which
// listeners hear it -- this means that the check for "am I the exclusive stream"
// has to be set up with the state of the system at the time the event is fired


class _SignalData<T> {
    T data;
    SignalSubscription exclusiveSignalSubscription;
    _SignalData(this.data, this.exclusiveSignalSubscription);
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
    SignalSubscription exclusiveSignalSubscription;

    Signal({String name}) {
        _name = name;
        _controller = new StreamController.broadcast();
    }

    String get name => _name;

    SignalSubscription subscribe(SignalHandler<T> userHandler, {String name}) {
        var streamSubscription = _controller.stream.listen(null);
        var mySignalSubscription = new SignalSubscription(streamSubscription, name: name);

        var wrappingHandler = (_SignalData<T> data) {
            ////var exName = (data.exclusiveSignalSubscription == null) ? "*" : data.exclusiveSignalSubscription.name;
            ////print("in wrapping handler in stream $name for ${data.data} with exclusive for $exName");

            if (data.exclusiveSignalSubscription == null) {
                // if it's null, send the signal to everyone
                ////print("** ${mySignalSubscription.name} getting nonexclusively");
                userHandler(data.data);
            } else {
                // we are operating in exclusive mode
                if (data.exclusiveSignalSubscription == mySignalSubscription) {
                    // the signal is for me, run the handler
                    ////print("** ${mySignalSubscription.name} executing exclusively");
                    userHandler(data.data);
                } else {
                    // the signal is not for me, do nothing
                    ////print("** ${mySignalSubscription.name} ignoring");
                }
            }
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
        var data = new _SignalData<T>(t, exclusiveSignalSubscription);
        ////var exName = (data.exclusiveSignalSubscription==null) ? "*" : data.exclusiveSignalSubscription.name;
        ////print("firing for ${data.data} with exclusive for $exName");
        _controller.add(data);
    }

    Future close() => _controller.close();
}


/*
int counterA = 0;
int counterB = 0;
int counterC = 0;

void testExclusive() {

    var signal = new Signal<int>();

    var subA, subB, subC;

    var hA = (int i) {
        counterA += i;
    };

    var hB = (int i) {
        counterB += i;
    };

    var hC = (int i) {
        counterC += i;
    };

    subA = signal.subscribe(hB, name: "A");
    subB = signal.subscribe(hB, name: "B");
    subC = signal.subscribe(hB, name: "C");

    signal.exclusiveSignalSubscription = subB;
    signal.fire(17);
    signal.fire(3);
    signal.fire(6);

    signal.exclusiveSignalSubscription = null;
    signal.fire(100);

    signal.exclusiveSignalSubscription = subA;
    signal.fire(112);

    signal.close().then((_) {
    });
}
*/