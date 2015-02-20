// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


var JsBridge = function () {

    this.registerDialog = function (dialogId) {
        'use strict';

        var dialog = document.querySelector(dialogId);
        myassert(dialog);

        dialogPolyfill.registerDialog(dialog);
    }

    this.showDialog = function (dialogId) {
        'use strict';

        var dialog = document.querySelector(dialogId);
        myassert(dialog);

        dialog.show();
    }

    this.showModalDialog = function (dialogId) {
        'use strict';

        var dialog = document.querySelector(dialogId);
        myassert(dialog);

        dialog.showModal();
    }

    this.closeDialog = function (dialogId, ret) {
        'use strict';

        var dialog = document.querySelector(dialogId);
        myassert(dialog);

        dialog.close(ret);
    }

    this.getDialogReturnValue = function (dialogId) {
        'use strict';

        var dialog = document.querySelector(dialogId);
        myassert(dialog);

        return dialog.returnValue;
    }
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

    console.log(s);
};
