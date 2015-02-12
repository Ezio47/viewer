// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class Comms {
    static Future<String> httpGet(url) {

        var c = new Completer<String>();

        Http.Client client = new BHttp.BrowserClient();

        client.get(url).then((response) {
            c.complete(response.body);
        }).catchError((e) {
            Hub.error("error getting script: $e");
        });

        return c.future;
    }
}
