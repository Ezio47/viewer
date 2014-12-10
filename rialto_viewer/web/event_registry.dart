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

    EventRegistry() {
        _hub = Hub.root;
    }

    SignalFunctionsT<MouseMoveData> MouseMove = new SignalFunctionsT<MouseMoveData>();

    SignalFunctions0 MouseDown = new SignalFunctions0();
    SignalFunctions0 MouseUp = new SignalFunctions0();

    SignalFunctions0 WindowResize = new SignalFunctions0();

    SignalFunctionsT<Vector3> MouseGeoCoords = new SignalFunctionsT<Vector3>();

    SignalFunctionsT<bool> DisplayAxes = new SignalFunctionsT<bool>();

    SignalFunctionsT<bool> DisplayBbox = new SignalFunctionsT<bool>();

    SignalFunctionsT<DisplayLayerData> DisplayLayer = new SignalFunctionsT<DisplayLayerData>();

    SignalFunctions0 ColorizeLayers = new SignalFunctions0();

    SignalFunctionsT<Vector3> UpdateCameraEyePosition = new SignalFunctionsT<Vector3>();
    SignalFunctionsT<Vector3> UpdateCameraTargetPosition = new SignalFunctionsT<Vector3>();

    SignalFunctionsT<String> UpdateColorizationSettings = new SignalFunctionsT<String>();

    SignalFunctionsT<String> OpenServer = new SignalFunctionsT<String>();
    SignalFunctions0 OpenServerCompleted = new SignalFunctions0();
    SignalFunctions0 CloseServer = new SignalFunctions0();
    SignalFunctions0 CloseServerCompleted = new SignalFunctions0();

    SignalFunctionsT<String> OpenFile = new SignalFunctionsT<String>();
    SignalFunctionsT<String> OpenFileCompleted = new SignalFunctionsT<String>();
    SignalFunctionsT<String> CloseFile = new SignalFunctionsT<String>();
    SignalFunctionsT<String> CloseFileCompleted = new SignalFunctionsT<String>();
}

class MouseMoveData {
    int newX;
    int newY;
    CanvasElement canvas;
    MouseMoveData(this.newX, this.newY, this.canvas);
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
