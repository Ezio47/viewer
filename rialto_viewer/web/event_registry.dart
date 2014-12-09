// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


//
// All components should register themselves with the hub and then
// express interest in whatever events they care about.
//
// For polymer elements, this is done in ready() or maybe attached()
//

typedef void MouseMoveHandler(int newX, int newY);
typedef void MouseDownHandler();
typedef void MouseUpHandler();
typedef void WindowResizeHandler();


class EventRegistry {
    // global handlers
    Signal<MouseMoveData> _mouseMoveSignal = new Signal<MouseMoveData>();
    Signal<MouseDownData> _mouseDownSignal = new Signal<MouseDownData>();
    Signal<MouseUpData> _mouseUpSignal = new Signal<MouseUpData>();
    Signal<WindowResizeData> _windowResizeSignal = new Signal<WindowResizeData>();

    Hub _hub;

    EventRegistry() {
        _hub = Hub.root;
    }

    void start(var domElement) {
        // translate system events into our kinds of signals
        domElement.onMouseMove.listen((e) => _mouseMoveSignal.fire(new MouseMoveData(e.client.x, e.client.y)));
        domElement.onMouseDown.listen((e) => _mouseDownSignal.fire(new MouseDownData()));
        domElement.onMouseUp.listen((e) => _mouseUpSignal.fire(new MouseUpData()));
        window.onResize.listen((e) => _windowResizeSignal.fire(new WindowResizeData(e.client.x, e.client.y)));
    }

    void subscribeMouseMove(Handler<MouseMoveData> handler) => _mouseMoveSignal.subscribe(handler);
    void unsubscribeMouseMove(Handler<MouseMoveData> handler) => _mouseMoveSignal.unsubscribe(handler);
    void fireMouseMoveHandler(MouseMoveData data) => _mouseMoveSignal.fire(data);

    void subscribeMouseDown(Handler<MouseDownData> handler) => _mouseDownSignal.subscribe(handler);
    void unsubscribeMouseDown(Handler<MouseDownData> handler) => _mouseDownSignal.unsubscribe(handler);
    void fireMouseDown(MouseDownData data) => _mouseDownSignal.fire(data);

    void subscribeMouseUp(Handler<MouseUpData> handler) => _mouseUpSignal.subscribe(handler);
    void unsubscribeMouseUp(Handler<MouseUpData> handler) => _mouseUpSignal.unsubscribe(handler);
    void fireMouseUp(MouseUpData data) => _mouseUpSignal.fire(data);

    void subscribeWindowResize(Handler<WindowResizeData> handler) => _windowResizeSignal.subscribe(handler);
    void unsubscribeWindowResize(Handler<WindowResizeData> handler) => _windowResizeSignal.unsubscribe(handler);
    void fireWindowResize(WindowResizeData data) => _windowResizeSignal.fire(data);
}


class MouseMoveData extends SignalData {
    int newX;
    int newY;
    MouseMoveData(this.newX, this.newY);
}

class MouseDownData extends SignalData {
    MouseDownData();
}

class MouseUpData extends SignalData {
    MouseUpData();
}

class WindowResizeData extends SignalData {
    int newWidth;
    int newHeight;
    WindowResizeData(this.newWidth, this.newHeight);
}
