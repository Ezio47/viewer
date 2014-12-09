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

class EventRegistry {
    Hub _hub;

    Signal<MouseMoveData> _mouseMoveSignal = new Signal<MouseMoveData>();
    Signal<MouseDownData> _mouseDownSignal = new Signal<MouseDownData>();
    Signal<MouseUpData> _mouseUpSignal = new Signal<MouseUpData>();
    Signal<WindowResizeData> _windowResizeSignal = new Signal<WindowResizeData>();
    Signal<GeoCoordsData> _mouseGeoCoordsSignal = new Signal<GeoCoordsData>();
    Signal<BoolData> _displayAxesSignal = new Signal<BoolData>();
    Signal<BoolData> _displayBboxSignal = new Signal<BoolData>();
    Signal<DisplayLayerData> _displayLayerSignal = new Signal<DisplayLayerData>();
    Signal _updateRendererSignal = new Signal();
    Signal _colorizeLayersSignal = new Signal();

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

    void subscribeMouseGeoCoords(Handler<GeoCoordsData> handler) => _mouseGeoCoordsSignal.subscribe(handler);
    void unsubscribeMouseGeoCoord(Handler<GeoCoordsData> handler) => _mouseGeoCoordsSignal.unsubscribe(handler);
    void fireMouseGeoCoord(GeoCoordsData data) => _mouseGeoCoordsSignal.fire(data);

    void subscribeDisplayAxes(Handler<BoolData> handler) => _displayAxesSignal.subscribe(handler);
    void unsubscribeDisplayAxes(Handler<BoolData> handler) => _displayAxesSignal.unsubscribe(handler);
    void fireDisplayAxes(BoolData data) => _displayAxesSignal.fire(data);

    void subscribeDisplayBbox(Handler<BoolData> handler) => _displayBboxSignal.subscribe(handler);
    void unsubscribeDisplayBbox(Handler<BoolData> handler) => _displayBboxSignal.unsubscribe(handler);
    void fireDisplayBbox(BoolData data) => _displayBboxSignal.fire(data);

    void subscribeDisplayLayer(Handler<DisplayLayerData> handler) => _displayLayerSignal.subscribe(handler);
    void unsubscribeDisplayLayer(Handler<DisplayLayerData> handler) => _displayLayerSignal.unsubscribe(handler);
    void fireDisplayLayer(DisplayLayerData data) => _displayLayerSignal.fire(data);

    // BUG: you can't unsubscribe the "empty" handler, since is an anonymous lambda
    void subscribeUpdateRenderer(Handler handler) => _updateRendererSignal.subscribe(handler);
    void unsubscribeUpdateRenderer(Handler handler) => _updateRendererSignal.unsubscribe(handler);
    void fireUpdateRenderer() => _updateRendererSignal.fire(null);

    void subscribeColorizeLayers(Handler handler) => _colorizeLayersSignal.subscribe(handler);
    void unsubscriberColorizeLayers(Handler handler) => _colorizeLayersSignal.unsubscribe(handler);
    void fireColorizeLayers() => _colorizeLayersSignal.fire(null);
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

class GeoCoordsData extends SignalData {
    double x;
    double y;
    GeoCoordsData(this.x, this.y);
}

class BoolData {
    bool v;
    BoolData(this.v);
}

class DisplayLayerData {
    String webpath;
    bool on;
    DisplayLayerData(this.webpath, this.on);
}
