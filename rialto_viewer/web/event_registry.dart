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

    SignalFunctions<ColorizeLayersData> ColorizeLayers = new SignalFunctions<ColorizeLayersData>();

    SignalFunctions<CameraData> UpdateCamera = new SignalFunctions<CameraData>();
    SignalFunctions<ViewModeData> SetViewMode = new SignalFunctions<ViewModeData>();

    SignalFunctions<LayerData> AddLayer = new SignalFunctions<LayerData>();
    SignalFunctions<Layer> AddLayerCompleted = new SignalFunctions<Layer>();
    SignalFunctions<Layer> AddAllLayersCompleted = new SignalFunctions<Layer>();
    SignalFunctions<String> RemoveLayer = new SignalFunctions<String>();
    SignalFunctions<String> RemoveLayerCompleted = new SignalFunctions<String>();
    SignalFunctions RemoveAllLayers = new SignalFunctions();
    SignalFunctions RemoveAllLayersCompleted = new SignalFunctions();

    SignalFunctions<ModeData> ChangeMode = new SignalFunctions();

    SignalFunctions<String> LoadScript = new SignalFunctions<String>();
    SignalFunctions<String> LoadScriptCompleted = new SignalFunctions<String>();

    SignalFunctions<CartographicBbox> LayersBboxChanged = new SignalFunctions<CartographicBbox>();

    SignalFunctions<WpsRequestData> WpsRequest = new SignalFunctions<WpsRequestData>();
    SignalFunctions<WpsRequestCompletedData> WpsRequestCompleted = new SignalFunctions<WpsRequestCompletedData>();
}

class MouseData {
    final double x;
    final double y;
    final bool altKey;
    final int button; // 0==left, 1==middle, 2==right

    MouseData(MouseEvent ev):
        altKey = ev.altKey,
        button = ev.button,
        x = ev.client.x.toDouble(),
        y = ev.client.y.toDouble();

    MouseData.fromXy(num nx, num ny) :
        altKey = null,
        button = null,
        x = nx.toDouble(),
        y = ny.toDouble();

    MouseData.fromXyb(num nx, num ny, int this.button):
        altKey = null,
        x = nx.toDouble(),
        y = ny.toDouble();
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

    WheelData.fromD(num d) :
        delta = d.toDouble();
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
    static const int NORMAL_MODE = 0;
    static const int WORLDVIEW_MODE = 1;
    static const int DATAVIEW_MODE = 2;
    int viewMode;
    Cartographic3 eye; // cartographic
    Cartographic3 target; // cartographic
    Cartesian3 up; // cartesian
    double fov;
    CameraData(this.eye, this.target, this.up, this.fov) : viewMode=NORMAL_MODE;
    CameraData.fromMode(this.viewMode);
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
    static const int ANNOTATION = 4;
    static const int VIEWSHED = 5;
    static final name = {
        MEASUREMENT: "measurement",
        VIEW: "view",
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


class WpsRequestCompletedData {
}


class ColorizeLayersData {
    String ramp;
    String dimension;
    ColorizeLayersData(String this.ramp, String this.dimension);
}

class ViewModeData {
    static const int MODE_2D = 0;
    static const int MODE_25D = 1;
    static const int MODE_3D = 2;

    final int mode;

    ViewModeData(int this.mode);

    static String name(int m) {
        if (m == ViewModeData.MODE_2D) return "2D";
        if (m == ViewModeData.MODE_25D) return "2.5D";
        if (m == ViewModeData.MODE_3D) return "3D";
        throw new ArgumentError("bad view mode value");
    }
}
