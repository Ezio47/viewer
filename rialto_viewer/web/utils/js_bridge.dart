// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class JsBridge {
    JsObject _bridge;

    JsBridge() {
        _bridge = new JsObject(context['JsBridge'], []);
    }

    dynamic registerDialog(String dialogId) {
        assert(dialogId.startsWith("#"));
        return _bridge.callMethod('registerDialog', [dialogId]);
    }

    void showDialog(dynamic dialog) {
        _bridge.callMethod('showDialog', [dialog]);
    }

    void showModalDialog(dynamic dialog) {
        _bridge.callMethod('showModalDialog', [dialog]);
    }

    void closeDialog(dynamic dialog, String value) {
        _bridge.callMethod('closeDialog', [dialog, value]);
    }

    dynamic getDialogReturnValue(dynamic dialog) {
        return _bridge.callMethod('getDialogReturnValue', [dialog]);
    }
}
