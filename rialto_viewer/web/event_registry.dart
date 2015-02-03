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

    // TODO: note you can't unsubscribe a handler that is an anonymous lambda
    // which might be the case of 0-arity handler functions

    EventRegistry();

    SignalFunctions<MouseData> MouseMove = new SignalFunctions<MouseData>();
    SignalFunctions<MouseData> MouseDown = new SignalFunctions<MouseData>();
    SignalFunctions<MouseData> MouseUp = new SignalFunctions<MouseData>();
    SignalFunctions<WheelData> MouseWheel = new SignalFunctions<WheelData>();

    SignalFunctions<KeyboardData> KeyDown = new SignalFunctions<KeyboardData>();
    SignalFunctions<KeyboardData> KeyUp = new SignalFunctions<KeyboardData>();

    SignalFunctions<Vector3> MouseGeoCoords = new SignalFunctions<Vector3>();

    SignalFunctions<bool> DisplayBbox = new SignalFunctions<bool>();

    SignalFunctions<DisplayLayerData> DisplayLayer = new SignalFunctions<DisplayLayerData>();

    SignalFunctions<String> ColorizeLayers = new SignalFunctions<String>();

    SignalFunctions<CameraData> UpdateCamera = new SignalFunctions<CameraData>();

    SignalFunctions<LayerData> AddLayer = new SignalFunctions<LayerData>();
    SignalFunctions<Layer> AddLayerCompleted = new SignalFunctions<Layer>();
    SignalFunctions<String> RemoveLayer = new SignalFunctions<String>();
    SignalFunctions<String> RemoveLayerCompleted = new SignalFunctions<String>();
    SignalFunctions RemoveAllLayers = new SignalFunctions();
    SignalFunctions RemoveAllLayersCompleted = new SignalFunctions();

    SignalFunctions<ModeData> ChangeMode = new SignalFunctions();

    SignalFunctions<String> LoadScript = new SignalFunctions<String>();
    SignalFunctions<String> LoadScriptCompleted = new SignalFunctions<String>();

    SignalFunctions<CartographicBbox> LayersBboxChanged = new SignalFunctions<CartographicBbox>();

    SignalFunctions<WpsRequestData> WpsRequest = new SignalFunctions<WpsRequestData>();
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
    Layer layer;
    bool visible;
    DisplayLayerData(this.layer, this.visible);
}

class CameraData {
    int mode; // 0:normal, 1:worldview, 2:dataview
    Cartographic3 eye; // cartographic
    Cartographic3 target; // cartographic
    Cartesian3 up; // cartesian
    double fov;
    CameraData(this.eye, this.target, this.up, this.fov) : mode=0;
    CameraData.fromMode(this.mode);
}

class LayerData {
    String name;
    Map map;
    LayerData(String this.name, Map this.map);
}

class ModeData {
    static const int INVALID = 0;
    static const int MEASUREMENT = 1;
    static const int VIEW = 2;
    static const int SELECTION = 3;
    static const int ANNOTATION = 4;
    static const int VIEWSHED = 5;
    static final name = {
        MEASUREMENT: "measurement",
        VIEW: "view",
        SELECTION: "selection",
        ANNOTATION: "annotation",
        VIEWSHED: "viewshed"
    };

    int type;

    ModeData(int this.type);
}

class WpsRequestData {
    static const int INVALID = 0;
    static const int VIEWSHED = 1;
    static final name = {
        VIEWSHED: "viewshed"
    };

    final int type;
    final List<Object> params;

    WpsRequestData(int this.type, List<Object> this.params);
}
