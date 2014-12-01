import 'dart:core';
import 'package:watcher/watcher.dart';
import 'proxy.dart';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
//import 'package:shelf_route/shelf_route.dart';
import 'package:shelf_route/shelf_route.dart' as r;
import 'package:shelf_exception_response/exception_response.dart';
import 'dart:convert';

DirectoryWatcher watcher;

void main() {

    var router = r.router()
            ..get('/', (_) => new Response.notFound(null), middleware: logRequests())
            ..get('/points/{+file}', getPoints, middleware: logRequests())
            ..get('/file/{+file}', getFile, middleware: logRequests());

    var handler =
            const Pipeline().addMiddleware(logRequests()).addMiddleware(exceptionResponse()).addHandler(router.handler);

    r.printRoutes(router);

    io.serve(handler, 'localhost', 12345).then((server) {
        print('Serving at http://${server.address.host}:${server.port}');
    });
}

Response getPoints(dynamic request) {
    var a = "Content-Type";
    var b = "application/json";
    var m = {
        a: b,
        "Access-Control-Allow-Origin": "*, ",
        "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
        "Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept"
    };
    //var s = "Contents of ${r.getPathParameter(request, 'file')}";
    var ms = [[0, 0, 0], [1, 1, 1], [2, 2, 2], [4, 4, 4], [16, 16, 16], [64, 64, 64]];
    var s = JSON.encode(ms);
    return new Response.ok(s, headers: m);
}


Response getFile(dynamic request) {
    var a = "Content-Type";
    var b = "application/json";
    var m = {
        a: b
    };
    //var s = "Contents of ${r.getPathParameter(request, 'file')}";
    var ms = {
        "a": "alpha",
        "b": "beta"
    };
    var s = JSON.encode(ms);
    return new Response.ok(s, headers: m);
}



void runWatcher(String srcDir) {
    final String testfile = srcDir + "/foo";

    if (FileSystemEntity.isFileSync(testfile)) {
        new File(testfile).deleteSync(recursive: false);
        sleep(new Duration(seconds: 1));
    }
    assert(FileSystemEntity.isFileSync(testfile) == false);

    var fs = new ProxyFileSystem.build(srcDir);
    fs.dump();

    // BUG: a file could be added between the initial crawl and the watching becoming ready

    watcher = new DirectoryWatcher(srcDir);

    watcher.events.listen(fs.handleWatchEvent);

    watcher.ready.then((onValue) {
        new File(testfile).createSync(recursive: false);
        print("*3");
        fs.dump();
    });

    print("*4");
}
