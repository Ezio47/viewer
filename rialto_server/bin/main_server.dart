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

        if (webpath.startsWith("/___")) {
            var x = (request.requestedUri.toString()).split("/___");
            x = x[1];
            print("***" + x);

            var uri = Uri.parse(x);

            String data;

            var cli = new HttpClient();
            cli.getUrl(uri).then((HttpClientRequest request) => request.close()).then((HttpClientResponse response) {
                response.transform(UTF8.decoder).listen((contents) {
                    print("GOT:$contents");
                    data = "$contents";
                    print("SENDING: $data");
                    return new Response.ok(data, headers: headers);
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
