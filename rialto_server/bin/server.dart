// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

library rialto.server;

import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_exception_response/exception_response.dart';


var srcDir;

void main(List<String> args) {
    var env = Platform.environment["HOME"];
    srcDir = "$env/work/dev/tuple/data";
    print("Running in $srcDir");

    if (args[0] == "main") {
        runMainServer();
    } else if (args[0] == "point" || args[0] == "points") {
        runPointServer();
    } else {
        print("Unknown server requested: ${args[0]}");
        exit(1);
    }
}


void runMainServer() {

    var router = shelf_route.router()
            ..get('/{+file}', _getFile, middleware: logRequests());

    var httpHandler =
            const Pipeline().addMiddleware(logRequests()).addMiddleware(exceptionResponse()).addHandler(router.handler);

    shelf_route.printRoutes(router);

    Future<HttpServer> fserver = shelf_io.serve(httpHandler, 'localhost', 12346).then((server) {
        print('Main server at http://${server.address.host}:${server.port}');
    });

}

void runPointServer() {

    var router = shelf_route.router()
            ..get('/{+file}', webSocketHandler(_getPoints), middleware: logRequests());

    var httpHandler =
            const Pipeline().addMiddleware(logRequests()).addMiddleware(exceptionResponse()).addHandler(router.handler);

    shelf_route.printRoutes(router);

    Future<HttpServer> fserver = shelf_io.serve(httpHandler, 'localhost', 12347).then((server) {
        print('Point server at http://${server.address.host}:${server.port}');
    });

}

void _getPoints(websocket) {
    websocket.listen((webpath) {
        webpath = srcDir + webpath;
        print("server hears request for points for: $webpath");

        int totalBytes = 0;
        File f = new File(webpath);
        Stream s = f.openRead();
        s.listen((bytes) {
            websocket.add(bytes);
            //print("sent ${bytes.length} bytes");
            totalBytes += bytes.length;
        }, onDone: () {
            print("sent $totalBytes bytes");
            websocket.close();
        });
    });
    return;
}


final headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*, ",
    "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
    "Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept"
};


Response _getFile(dynamic request) {
    final String webpath = request.scriptName;
    print("requesting file from: $srcDir + $webpath");

    File file = new File(srcDir + webpath);
    if (file == null) {
        return new Response.notFound(null, headers: headers);
    }
    var data = file.openRead();
    return new Response.ok(data, headers: headers);
}
