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

    // BUG: note you can't unsubscribe a handler that is an anonymous lambda
    // which might be the case of 0-arity handler functions

    Signal<MouseMoveData> _mouseMoveSignal = new Signal<MouseMoveData>();
    Signal _mouseDownSignal = new Signal();
    Signal _mouseUpSignal = new Signal();
    Signal _windowResizeSignal = new Signal();
    Signal<Vector3> _mouseGeoCoordsSignal = new Signal<Vector3>();
    Signal<bool> _displayAxesSignal = new Signal<bool>();
    Signal<bool> _displayBboxSignal = new Signal<bool>();
    Signal<DisplayLayerData> _displayLayerSignal = new Signal<DisplayLayerData>();
    Signal _colorizeLayersSignal = new Signal();
    Signal<Vector3> _updateCameraEyePositionSignal = new Signal<Vector3>();
    Signal<Vector3> _updateCameraTargetPositionSignal = new Signal<Vector3>();
    //Signal<double> _updateZScaleSignal = new Signal<double>();
    Signal<String> _updateColorizationSettingsSignal = new Signal<String>();

    Signal<String> _openServerSignal = new Signal<String>();
    Signal _openServerCompletedSignal = new Signal();
    Signal _closeServerSignal = new Signal();
    Signal _closeServerCompletedSignal = new Signal();

    Signal<String> _openFileSignal = new Signal<String>();
    Signal _openFileCompletedSignal = new Signal();
    Signal<String> _closeFileSignal = new Signal<String>();
    Signal _closeFileCompletedSignal = new Signal();

    EventRegistry() {
        _hub = Hub.root;
    }

    void start(var domElement) {
        // translate system events into our kinds of signals
        domElement.onMouseMove.listen((e) => _mouseMoveSignal.fire(new MouseMoveData(e.client.x, e.client.y)));
        domElement.onMouseDown.listen((e) => _mouseDownSignal.fire(null));
        domElement.onMouseUp.listen((e) => _mouseUpSignal.fire(null));
        window.onResize.listen((e) => _windowResizeSignal.fire(null));
    }

    void subscribeMouseMove(Handler<MouseMoveData> handler) => _mouseMoveSignal.subscribe(handler);
    void unsubscribeMouseMove(Handler<MouseMoveData> handler) => _mouseMoveSignal.unsubscribe(handler);
    void fireMouseMoveHandler(MouseMoveData data) => _mouseMoveSignal.fire(data);

    void subscribeMouseDown(Handler handler) => _mouseDownSignal.subscribe(handler);
    void unsubscribeMouseDown(Handler handler) => _mouseDownSignal.unsubscribe(handler);
    void fireMouseDown() => _mouseDownSignal.fire(null);

    void subscribeMouseUp(Handler handler) => _mouseUpSignal.subscribe(handler);
    void unsubscribeMouseUp(Handler handler) => _mouseUpSignal.unsubscribe(handler);
    void fireMouseUp() => _mouseUpSignal.fire(null);

    void subscribeWindowResize(Handler handler) => _windowResizeSignal.subscribe(handler);
    void unsubscribeWindowResize(Handler handler) => _windowResizeSignal.unsubscribe(handler);
    void fireWindowResize() => _windowResizeSignal.fire(null);

    void subscribeMouseGeoCoords(Handler<Vector3> handler) => _mouseGeoCoordsSignal.subscribe(handler);
    void unsubscribeMouseGeoCoord(Handler<Vector3> handler) => _mouseGeoCoordsSignal.unsubscribe(handler);
    void fireMouseGeoCoord(Vector3 data) => _mouseGeoCoordsSignal.fire(data);

    void subscribeDisplayAxes(Handler<bool> handler) => _displayAxesSignal.subscribe(handler);
    void unsubscribeDisplayAxes(Handler<bool> handler) => _displayAxesSignal.unsubscribe(handler);
    void fireDisplayAxes(bool data) => _displayAxesSignal.fire(data);

    void subscribeDisplayBbox(Handler<bool> handler) => _displayBboxSignal.subscribe(handler);
    void unsubscribeDisplayBbox(Handler<bool> handler) => _displayBboxSignal.unsubscribe(handler);
    void fireDisplayBbox(bool data) => _displayBboxSignal.fire(data);

    void subscribeDisplayLayer(Handler<DisplayLayerData> handler) => _displayLayerSignal.subscribe(handler);
    void unsubscribeDisplayLayer(Handler<DisplayLayerData> handler) => _displayLayerSignal.unsubscribe(handler);
    void fireDisplayLayer(DisplayLayerData data) => _displayLayerSignal.fire(data);

    void subscribeColorizeLayers(Handler handler) => _colorizeLayersSignal.subscribe(handler);
    void unsubscribeColorizeLayers(Handler handler) => _colorizeLayersSignal.unsubscribe(handler);
    void fireColorizeLayers() => _colorizeLayersSignal.fire(null);

    void subscribeUpdateCameraEyePosition(Handler<Vector3> handler) => _updateCameraEyePositionSignal.subscribe(handler);
    void unsubscribeUpdateCameraEyePosition(Handler<Vector3> handler) => _updateCameraEyePositionSignal.unsubscribe(handler);
    void fireUpdateCameraEyePosition(Vector3 data) => _updateCameraEyePositionSignal.fire(data);

    void subscribeUpdateCameraTargetPosition(Handler<Vector3> handler) => _updateCameraTargetPositionSignal.subscribe(handler);
    void unsubscribeUpdateCameraTargetPosition(Handler<Vector3> handler) => _updateCameraTargetPositionSignal.unsubscribe(handler);
    void fireUpdateCameraTargetPosition(Vector3 data) => _updateCameraTargetPositionSignal.fire(data);

    //void subscribeUpdateZScale(Handler<double> handler) => _updateZScaleSignal.subscribe(handler);
    //void unsubscribeUpdateZScale(Handler<double> handler) => _updateZScaleSignal.unsubscribe(handler);
    //void fireUpdateZScale(double data) => _updateZScaleSignal.fire(data);

    void subscribeUpdateColorizationSettings(Handler<String> handler) => _updateColorizationSettingsSignal.subscribe(handler);
    void unsubscribeUpdateColorizationSettings(Handler<String> handler) => _updateColorizationSettingsSignal.unsubscribe(handler);
    void fireUpdateColorizationSettings(String data) => _updateColorizationSettingsSignal.fire(data);

    ///
    void subscribeOpenServer(Handler<String> handler) => _openServerSignal.subscribe(handler);
    void unsubscribeOpenServer(Handler<String> handler) => _openServerSignal.unsubscribe(handler);
    void fireOpenServer(String data) => _openServerSignal.fire(data);

    void subscribeOpenServerCompleted(Handler handler) => _openServerCompletedSignal.subscribe(handler);
    void unsubscribeOpenServerCompleted(Handler handler) => _openServerCompletedSignal.unsubscribe(handler);
    void fireOpenServerCompleted() => _openServerCompletedSignal.fire(null);

    void subscribeCloseServer(Handler handler) => _closeServerSignal.subscribe(handler);
    void unsubscribeCloseServer(Handler handler) => _closeServerSignal.unsubscribe(handler);
    void fireCloseServer() => _closeServerSignal.fire(null);

    void subscribeCloseServerCompleted(Handler handler) => _closeServerCompletedSignal.subscribe(handler);
    void unsubscribeCloseServerCompleted(Handler handler) => _closeServerCompletedSignal.unsubscribe(handler);
    void fireCloseServerCompleted() => _closeServerCompletedSignal.fire(null);

    ///
    void subscribeOpenFile(Handler<String> handler) => _openFileSignal.subscribe(handler);
    void unsubscribeOpenFile(Handler<String> handler) => _openFileSignal.unsubscribe(handler);
    void fireOpenFile(String data) => _openFileSignal.fire(data);

    void subscribeOpenFileCompleted(Handler handler) => _openFileCompletedSignal.subscribe(handler);
    void unsubscribeOpenFileCompleted(Handler handler) => _openFileCompletedSignal.unsubscribe(handler);
    void fireOpenFileCompleted() => _openFileCompletedSignal.fire(null);

    void subscribeCloseFile(Handler<String> handler) => _closeServerSignal.subscribe(handler);
    void unsubscribeCloseFile(Handler<String> handler) => _closeServerSignal.unsubscribe(handler);
    void fireCloseFile(String data) => _closeServerSignal.fire(data);

    void subscribeCloseFileCompleted(Handler handler) => _closeFileCompletedSignal.subscribe(handler);
    void unsubscribeCloseFileCompleted(Handler handler) => _closeFileCompletedSignal.unsubscribe(handler);
    void fireCloseFileCompleted() => _closeFileCompletedSignal.fire(null);
}


class MouseMoveData {
    int newX;
    int newY;
    MouseMoveData(this.newX, this.newY);
}

class DisplayLayerData {
    String webpath;
    bool on;
    DisplayLayerData(this.webpath, this.on);
}

class CameraModelData {
    Vector3 cameraPosition;
    Vector3 eyePosition;
    double zExaggeartion;
    CameraModelData(this.cameraPosition, this.eyePosition, this.zExaggeartion);
}
