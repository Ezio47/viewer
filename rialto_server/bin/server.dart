// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

library rialto.server;

import 'dart:async';
//import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_exception_response/exception_response.dart';
//import 'package:watcher/watcher.dart';
//import 'package:path/path.dart' as path;

var srcDir;

void main() {
    var env = Platform.environment["HOME"];
    srcDir = "$env/work/dev/tuple/data";
    print("Running in $srcDir");

    runServer1();
//    runServer2();
}




void runServer1() {

    var router = shelf_route.router()
            //..get('/', (_) => new Response.notFound(null), middleware: logRequests())
            ..get('/points', webSocketHandler(_getPoints), middleware: logRequests())
            //..get('/file', _getFile, middleware: logRequests())
            ..get('/{+file}', _getFile, middleware: logRequests());

    var httpHandler =
            const Pipeline().addMiddleware(logRequests()).addMiddleware(exceptionResponse()).addHandler(router.handler);

    shelf_route.printRoutes(router);

    Future<HttpServer> fserver = shelf_io.serve(httpHandler, 'localhost', 12345).then((server) {
        print('Serving at http://${server.address.host}:${server.port}');
        //fauxClient();
    });

}

void fauxClient() {
    Future<WebSocket> fclient = WebSocket.connect('ws://localhost:12345/points/');
    fclient.then((ws) {
        ws.add("/a/b/c"); // {+file}
        ws.listen((List<int> intlist) {
            print("client hears: $intlist");
            ws.close();
            Uint8List list = new Uint8List.fromList(intlist);
            print("client really hears: $list");
        });
    });
}


void _getPoints(websocket) {
    websocket.listen((webpath) {
        print("server hears request for points for: $webpath");


        File f = new File(webpath);
        Stream s = f.openRead();
        s.listen((bytes) {
            websocket.add(bytes);
            print("sent ${bytes.length} bytes");
        }, onDone: () {
            print("file closed");
            websocket.close();
        });
    });
    return;
}


String normalize(Request request, String prefix) {
    assert(request.scriptName.startsWith(prefix));
    var path = request.scriptName.substring(prefix.length);
    if (path.isEmpty) path = "/";
    return path;
}


var headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*, ",
    "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
    "Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept"
};


Future toFuture(dynamic v) {
    Completer c = new Completer();
    c.complete(v);
    return c.future;
}


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
