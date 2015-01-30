// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.server;


var srcDir;


class MainServer extends Server {
    MainServer(String server, int port, String dir) : super("Main", server, port, dir) {
        _handlerGET = _processFile;
    }

    Response _processFile(dynamic request) {
        final String webpath = request.scriptName;
        print("requesting file from: $dir + $webpath");

        if (webpath.startsWith("/x")) {
            var x = request.requestedUri.toString().substring(2);
            print("***** $x");
            var xx = x.split("EEE");
            print("***** $xx");

            print(request);

            var host = xx[0];
            int port = 80;
            var path = xx[1];
            print("HOST:" + host);
            print("PORT: $port");
            print("PATH:" + path);

            new HttpClient().get(
                    host,
                    port,
                    path).then((HttpClientRequest request) => request.close()).then((HttpClientResponse response) {
                response.transform(UTF8.decoder).listen((contents) {
                    print(contents);
                });
            });
        } else {
            File file = new File(dir + webpath);
            if (file == null) {
                return new Response.notFound(null, headers: headers);
            }
            var data = file.openRead();
            return new Response.ok(data, headers: headers);
        }
    }
}
