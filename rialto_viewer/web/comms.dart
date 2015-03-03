// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class Comms {
    static Future<dynamic> httpGet(Uri url, {Uri proxyUri: null}) {

        var c = new Completer<dynamic>();

        String s = url.toString();

        if (proxyUri != null) {
            s = proxyUri.toString() + "?" + s;
            url = Uri.parse(s);
        }

        Http.Client client = new BHttp.BrowserClient();

        client.get(url).then((response) {
            c.complete(response);
        }).catchError((e) {
            Hub.error("Unable to load file", object: e, info: {"Path": url});
        });

        return c.future;
    }
}
