// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

//
// All components should register themselves with the hub and then
// express interest in whatever events they care about.
//

class EventRegistry {

    // TODO: note you can't unsubscribe a handler that is an anonymous lambda
    // which might be the case of 0-arity handler functions

    EventRegistry();

    SignalFunctions<MouseData> MouseMove = new SignalFunctions<MouseData>();

    SignalFunctions<AdvancedSettingsChangedData> AdvancedSettingsChanged = new SignalFunctions<AdvancedSettingsChangedData>();

    SignalFunctions<Layer> AddLayerCompleted = new SignalFunctions<Layer>();
    SignalFunctions<Layer> AddAllLayersCompleted = new SignalFunctions<Layer>();
    SignalFunctions<Layer> RemoveLayerCompleted = new SignalFunctions<Layer>();
    SignalFunctions RemoveAllLayersCompleted = new SignalFunctions();

    SignalFunctions<String> LoadScriptCompleted = new SignalFunctions<String>();

    SignalFunctions<WpsJobUpdateData> WpsJobUpdate = new SignalFunctions<WpsJobUpdateData>();
}


class AdvancedSettingsChangedData {
    bool showBbox;
    int displayPrecision;

    AdvancedSettingsChangedData(this.showBbox, this.displayPrecision);
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


class WpsJobUpdateData {
    final int jobId; // some change has happened with respect to this job

    WpsJobUpdateData(int this.jobId);
}
