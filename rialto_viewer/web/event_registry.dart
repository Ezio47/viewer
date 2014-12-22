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

    SignalFunctions<MouseData> MouseMove = new SignalFunctions<MouseData>();
    SignalFunctions<MouseData> MouseDown = new SignalFunctions<MouseData>();
    SignalFunctions<MouseData> MouseUp = new SignalFunctions<MouseData>();

    SignalFunctions<KeyboardData> KeyDown = new SignalFunctions<KeyboardData>();
    SignalFunctions<KeyboardData> KeyUp = new SignalFunctions<KeyboardData>();

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

class MouseData {
    int x;
    int y;
    bool altKey;
    int button;
    CanvasElement canvas;
    MouseData(MouseEvent ev) {
        altKey = ev.altKey;
        button = ev.button;
        x = ev.client.x;
        y = ev.client.y;
    }
}

class KeyboardData {
    bool controlKey;
    bool altKey;
    bool shiftKey;
    int keyCode;

    static const int KEY_UP = 38;
    static const int KEY_DOWN = 40;
    static const int KEY_RIGHT = 39;
    static const int KEY_LEFT = 37;
    static const int KEY_W = 87;
    static const int KEY_N = 78;

    KeyboardData(KeyboardEvent ev) {
       controlKey = ev.ctrlKey;
       shiftKey = ev.shiftKey;
       altKey = ev.altKey;
       keyCode = ev.keyCode;
    }
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
