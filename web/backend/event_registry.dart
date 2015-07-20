// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend;

/// Event handlers for the several events in the system.
///
/// The [Rialto] singleton contains exactly one instance of this class. This registry contains
/// each type of event that the system uses.
///
/// Components within the viewer may register their interest in an event (via subscribe())
/// or cause an event to happen (via fire()).
class EventRegistry {

  // TODO: note you can't unsubscribe a handler that is an anonymous lambda
  // which might be the case of 0-arity handler functions

  EventRegistry();

  SignalFunctions<MouseData> MouseMove = new SignalFunctions<MouseData>();

  SignalFunctions<AdvancedSettingsChangedData> AdvancedSettingsChanged =
      new SignalFunctions<AdvancedSettingsChangedData>();

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

enum MouseButton { left, middle, right, }

class MouseData {
  final double x;
  final double y;
  final bool altKey;
  final MouseButton button;

  static final _buttonMap = {0: MouseButton.left, 1: MouseButton.middle, 2: MouseButton.right};

  MouseData(MouseEvent ev)
      : altKey = ev.altKey,
        button = _buttonMap[ev.button],
        x = ev.client.x.toDouble(),
        y = ev.client.y.toDouble();

  MouseData.fromXy(num nx, num ny)
      : altKey = null,
        button = null,
        x = nx.toDouble(),
        y = ny.toDouble();

  MouseData.fromXyb(num nx, num ny, MouseButton this.button)
      : altKey = null,
        x = nx.toDouble(),
        y = ny.toDouble();
}

class WheelData {
  double delta;

  WheelData(WheelEvent event) {
    // (taken from Three.dart's trackball control)
    if (event.deltaY != 0) {
      // WebKit / Opera / Explorer 9
      delta = event.deltaY / 40;
    } else if (event.detail != 0) {
      // Firefox
      delta = -event.detail / 3;
    }
  }

  WheelData.fromD(num d) : delta = d.toDouble();
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

/// indicates that some change has happened with respect to the given job
class WpsJobUpdateData {
  final int jobId;

  WpsJobUpdateData(int this.jobId);
}
