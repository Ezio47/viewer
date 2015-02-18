// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.server;


class FileServer extends Server {
    FileServer(String server, int port, String dir) : super("Main", server, port, dir) {
        _handlerGET = _processFile;
    }

    Response _processFile(dynamic request) {
        final String webpath = request.scriptName;
        //print("Requesting file from: $dir + $webpath");

        var filename = dir + webpath;
        File file = null;

        try {
            file = new File(filename);
        } catch (e) {
            print("Unable to open file: $filename");
            print("Exception: $e");
            return new Response.notFound(null, headers: headers);
        }

        if (!file.existsSync()) {
            print("Unable to read file: $filename");
            return new Response.notFound(null, headers: headers);
        }

        Stream<List<int>> s = null;
        try {
            s = file.openRead();
        } catch (e) {
            print("Unable to read file: $filename");
            return new Response.notFound(null, headers: headers);
        }

        var r;
        try {
            r = new Response.ok(s, headers: headers);
        } catch (e) {
            print("Unable to read file: $filename");
            return new Response.notFound(null, headers: headers);
        }

        return r;
    }
}
