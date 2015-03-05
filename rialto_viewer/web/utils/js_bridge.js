// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


var mylogger = null;

var JsBridge = function (logger) {
    'use strict';

    mylogger = logger;

    // dialogId must include leading '#'
    this.registerDialog = function (dialogId) {
        var dialog = UIkit.modal(dialogId);
        return dialog;
    }

    this.showDialog = function (dialog) {
        dialog.show();
    }

    this.hideDialog = function (dialog, ret) {
        dialog.hide(ret);
    }

    mylog("yow");
}


var myassert = function (condition, message) {
    "use strict";

    if (!condition) {
        message = message || "Assertion failed";
        if (typeof Error !== "undefined") {
            throw new Error(message);
        }
        throw message; // Fallback
    }
};


var myerror = function (s, t) {
    "use strict";

    var text = "*** ERROR ***";

    if (s != undefined) {
        text += "\n" + s;
    }

    if (t != undefined) {
        text += "\n" + t;
    }

    mylog(text);
    //window.alert(text);
};


var mylog = function (s) {
    "use strict";

    if (mylogger != null) {
        mylogger(s);
    } else {
        console.log(s);
    }
};
