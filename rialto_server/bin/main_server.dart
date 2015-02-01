// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.server;


class MainServer extends Server {
    MainServer(String server, int port, String dir) : super("Main", server, port, dir) {
        _handlerGET = _processFile;
    }

    Response _processFile(dynamic request) {
        final String webpath = request.scriptName;
        print("requesting file from: $dir + $webpath");

        File file = new File(dir + webpath);
        if (file == null) {
            return new Response.notFound(null, headers: headers);
        }
        var data = file.openRead();
        return new Response.ok(data, headers: headers);
    }
}
