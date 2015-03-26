// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


/// Javascript debugging helpers
class JsBridge {
    JsObject _bridge;

    JsBridge(logger) {
        _bridge = new JsObject(context['JsBridge'], [logger]);
    }

    dynamic registerDialog(String dialogId) {
        assert(dialogId.startsWith("#"));
        return _bridge.callMethod('registerDialog', [dialogId]);
    }

    void showDialog(dynamic dialog) {
        _bridge.callMethod('showDialog', [dialog]);
    }

    void hideDialog(dynamic dialog) {
        _bridge.callMethod('hideDialog', [dialog]);
    }
}
