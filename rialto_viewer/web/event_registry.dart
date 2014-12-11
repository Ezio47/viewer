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

    SignalFunctions<MouseMoveData> MouseMove = new SignalFunctions<MouseMoveData>();

    SignalFunctions MouseDown = new SignalFunctions();
    SignalFunctions MouseUp = new SignalFunctions();

    SignalFunctions WindowResize = new SignalFunctions();

    SignalFunctions<Vector3> MouseGeoCoords = new SignalFunctions<Vector3>();

    SignalFunctions<bool> DisplayAxes = new SignalFunctions<bool>();

    SignalFunctions<bool> DisplayBbox = new SignalFunctions<bool>();

    SignalFunctions<DisplayLayerData> DisplayLayer = new SignalFunctions<DisplayLayerData>();

    SignalFunctions ColorizeLayers = new SignalFunctions();

    SignalFunctions<Vector3> UpdateCameraEyePosition = new SignalFunctions<Vector3>();
    SignalFunctions<Vector3> UpdateCameraTargetPosition = new SignalFunctions<Vector3>();

    SignalFunctions<String> UpdateColorizationSettings = new SignalFunctions<String>();

    SignalFunctions<String> OpenServer = new SignalFunctions<String>();
    SignalFunctions OpenServerCompleted = new SignalFunctions();
    SignalFunctions CloseServer = new SignalFunctions();
    SignalFunctions CloseServerCompleted = new SignalFunctions();

    SignalFunctions<String> OpenFile = new SignalFunctions<String>();
    SignalFunctions<String> OpenFileCompleted = new SignalFunctions<String>();
    SignalFunctions<String> CloseFile = new SignalFunctions<String>();
    SignalFunctions<String> CloseFileCompleted = new SignalFunctions<String>();

    SignalFunctions AnnotationMode = new SignalFunctions();
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
