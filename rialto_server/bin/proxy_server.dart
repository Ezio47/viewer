// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.server;


class ProxyServer extends Server {
    ProxyServer(String server, int port, String dir) : super("Main", server, port, dir) {
        _handlerGET = _processFile;
    }

    Future<Response> _processFile(dynamic request) {
        var c = new Completer<Response>();

        String fullUri = request.requestedUri.toString();
        print("requesting proxy of $fullUri");

        // .../x?q=%22...%22 ==> %22...%22
        var magic = "/x?q=";
        var idx = fullUri.indexOf(magic);
        var target = fullUri.substring(idx + magic.length, fullUri.length);

        // %22...%22 ==> ...
        target = target.replaceAll("%22",  "");

        var uri = Uri.parse(target);

        print("requesting proxy for $uri");

        getter(uri).then((s) {
            var r = new Response.ok(s, headers: headers);
            c.complete(r);
        });

        return c.future;
    }

    Future<String> getter(uri) {
        var c = new Completer<String>();

        var cli = new HttpClient();

        cli.getUrl(uri).then((HttpClientRequest request) => request.close()).then((HttpClientResponse response) {
            response.transform(UTF8.decoder).listen((contents) {
                c.complete(contents);
                // TODO: error handling
            });
        });

        return c.future;
    }
}
