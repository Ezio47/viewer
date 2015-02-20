// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class JsBridge {
    JsObject _bridge;

    JsBridge() {
        _bridge = new JsObject(context['JsBridge'], []);
    }

    void registerDialog(String dialogId) {
        assert(dialogId.startsWith("#"));
        _bridge.callMethod('registerDialog', [dialogId]);
    }

    void showDialog(String dialogId) {
        assert(dialogId.startsWith("#"));
        _bridge.callMethod('showDialog', [dialogId]);
    }

    void showModalDialog(String dialogId) {
        assert(dialogId.startsWith("#"));
        _bridge.callMethod('showModalDialog', [dialogId]);
    }

    void closeDialog(String dialogId, String value) {
        assert(dialogId.startsWith("#"));
        _bridge.callMethod('closeDialog', [dialogId, value]);
    }

    dynamic getDialogReturnValue(String dialogId) {
        assert(dialogId.startsWith("#"));
        return _bridge.callMethod('getDialogReturnValue', [dialogId]);
    }
}
