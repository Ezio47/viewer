// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
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

    // BUG: note you can't unsubscribe a handler that is an anonymous lambda
    // which might be the case of 0-arity handler functions

    EventRegistry();

    SignalFunctions<MouseData> MouseMove = new SignalFunctions<MouseData>();
    SignalFunctions<MouseData> MouseDown = new SignalFunctions<MouseData>();
    SignalFunctions<MouseData> MouseUp = new SignalFunctions<MouseData>();
    SignalFunctions<WheelData> MouseWheel = new SignalFunctions<WheelData>();

    SignalFunctions<KeyboardData> KeyDown = new SignalFunctions<KeyboardData>();
    SignalFunctions<KeyboardData> KeyUp = new SignalFunctions<KeyboardData>();

    SignalFunctions WindowResize = new SignalFunctions();

    SignalFunctions<Vector3> MouseGeoCoords = new SignalFunctions<Vector3>();

    SignalFunctions<bool> DisplayAxes = new SignalFunctions<bool>();

    SignalFunctions<bool> DisplayBbox = new SignalFunctions<bool>();

    SignalFunctions<DisplayLayerData> DisplayLayer = new SignalFunctions<DisplayLayerData>();

    SignalFunctions ColorizeLayers = new SignalFunctions();

    SignalFunctions MoveCameraHome = new SignalFunctions();

    SignalFunctions<String> UpdateColorizationSettings = new SignalFunctions<String>();

    SignalFunctions<String> OpenServer = new SignalFunctions<String>();
    SignalFunctions OpenServerCompleted = new SignalFunctions();
    SignalFunctions CloseServer = new SignalFunctions();
    SignalFunctions CloseServerCompleted = new SignalFunctions();

    SignalFunctions<String> OpenFile = new SignalFunctions<String>();
    SignalFunctions<String> OpenFileCompleted = new SignalFunctions<String>();
    SignalFunctions<String> CloseFile = new SignalFunctions<String>();
    SignalFunctions<String> CloseFileCompleted = new SignalFunctions<String>();

    SignalFunctions<ModeData> ChangeMode = new SignalFunctions();
}

class MouseData {
    int x;
    int y;
    bool altKey;
    int button; // 0==left, 1==middle, 2==right
    CanvasElement canvas;

    MouseData(MouseEvent ev) {
        altKey = ev.altKey;
        button = ev.button;
        x = ev.client.x;
        y = ev.client.y;
    }

    MouseData.fromXy(int this.x, int this.y);

    MouseData.fromXyb(int this.x, int this.y, int this.button);
}

class WheelData {
    double delta;
    WheelData(WheelEvent event) {
        // (taken from Three.dart's trackball control)
        if (event.deltaY != 0) { // WebKit / Opera / Explorer 9
            delta = event.deltaY / 40;
        } else if (event.detail != 0) { // Firefox
            delta = -event.detail / 3;
        }
    }
    WheelData.fromD(double d) {
        delta = d;
    }
}

class KeyboardData {
    bool controlKey;
    bool altKey;
    bool shiftKey;
    int keyCode;

    KeyboardData(KeyboardEvent ev) {
        controlKey = ev.ctrlKey;
        shiftKey = ev.shiftKey;
        altKey = ev.altKey;
        keyCode = ev.keyCode;
    }
}

class DisplayLayerData {
    String webpath;
    bool visible;
    DisplayLayerData(this.webpath, this.visible);
}

class CameraModelData {
    Vector3 cameraPosition;
    Vector3 eyePosition;
    double zExaggeartion;
    CameraModelData(this.cameraPosition, this.eyePosition, this.zExaggeartion);
}



class ModeData {
    static const int INVALID = 0;
    static const int MEASUREMENT = 1;
    static const int VIEW = 2;
    static const int SELECTION = 3;
    static const int ANNOTATION = 4;
    static final name = {
        MEASUREMENT: "measurement",
        VIEW: "view",
        SELECTION: "selection",
        ANNOTATION: "annotation"
    };

    int type;

    ModeData(int this.type);
}
