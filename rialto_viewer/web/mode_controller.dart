// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

// note we only allow one handler per mode type

class ModeController {
    Hub _hub;
    Map<int, IMode> _modes;
    IMode _currentMode;

    ModeController()
            : _hub = Hub.root,
              _modes = new Map<int, IMode>(),
              _currentMode = null {
        _hub.eventRegistry.ChangeMode.subscribe(_handleChangeMode);
    }

    void _handleChangeMode(ModeData ev) {
        if (!_modes.containsKey(ev.type)) return;

        if (_currentMode != null) {
            var type = _lookupType(_currentMode);
            print("ending mode ${ModeData.name[type]}");
            _currentMode.isRunning = false;
            _currentMode.endMode();
        }

        IMode thing = _modes[ev.type];
        _currentMode = thing;
        print("starting mode ${ModeData.name[ev.type]}");
        _currentMode.isRunning = true;
        _currentMode.startMode();
    }

    bool isEnabled(IMode thing) => (_currentMode == thing);

    void register(IMode thing, int type) {
        if (_modes.containsValue(thing)) return;

        _modes[type] = thing;
    }

    void unregister(IMode thing) {
        if (!_modes.containsValue(thing)) return;

        // remove the key with this value
        var type = _lookupType(thing);
        if (type != null) {
            _modes.remove(type);
        }
    }

    // inverse mapping
    int _lookupType(IMode mode) {
        for (var k in _modes.keys) {
            IMode m = _modes[k];
            if (m == mode) return k;
        }
        return null;
    }
}


abstract class IMode {
    bool isRunning;
    //bool get isRunning => _isRunning;
    //void set isRunning(bool v) { _isRunning = v; }
    void startMode();
    void endMode();
}
