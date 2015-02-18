// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


var myassert = function (b, s) {
    "use strict";

    if (b) return;

    if (s == undefined) {
        myerror("Assertion failed.");
    } else {
        myerror("Assertion failed: " + s);
    }
};


var myerror = function (s, t) {
    "use strict";

    mylog("*** ERROR ***");

    if (s != undefined) {
        mylog(s);
    }

    if (t != undefined) {
        mylog(t);
    }
};


var mylog = function (s) {
    "use strict";

    console.log(s);
};
