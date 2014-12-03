import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_route/shelf_route.dart' as r;
import 'package:shelf_exception_response/exception_response.dart';
import 'package:watcher/watcher.dart';

import 'proxy.dart';


DirectoryWatcher watcher;
ProxyFileSystem fileSystem;


void main() {
    var srcDir = "/Users/mgerlek/work/data";

    buildFileSystem(srcDir);

    // BUG: a file could be added between the initial crawl and the watching becoming ready

    runWatcher(srcDir);

    runServer();
}


void buildFileSystem(String srcDir) {
    fileSystem = new ProxyFileSystem.build(srcDir);
    //fileSystem.dump();
}


void runWatcher(String srcDir) {
    watcher = new DirectoryWatcher(srcDir);
    watcher.events.listen(fileSystem.handleWatchEvent);
}


void runServer() {
    var router = r.router()
            ..get('/', (_) => new Response.notFound(null), middleware: logRequests())
            ..get('/points/{+file}', _getPoints, middleware: logRequests())
            ..get('/file', _getFile, middleware: logRequests())
            ..get('/file/{+file}', _getFile, middleware: logRequests());

    var handler =
            const Pipeline().addMiddleware(logRequests()).addMiddleware(exceptionResponse()).addHandler(router.handler);

    r.printRoutes(router);

    io.serve(handler, 'localhost', 12345).then((server) {
        print('Serving at http://${server.address.host}:${server.port}');
    });
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


Future<Response> _getPoints(dynamic request) {
    final String webpath = normalize(request, "/points");
    print("requesting points from: $webpath");

    var proxy = fileSystem.getEntry(webpath);
    if (proxy == null) return toFuture(new Response.notFound(null)); // error

    if (proxy is! FileProxy) return toFuture(new Response.notFound(null));

    var fbytes = proxy.file.readAsBytes();
    var fbase64 = fbytes.then((bytes) => CryptoUtils.bytesToBase64(bytes, addLineSeparator: true));
    var resp = fbase64.then((data) => new Response.ok(data, headers: headers));
    return resp;
}


Response _getFile(dynamic request) {
    final String webpath = normalize(request, "/file");
    print("requesting file from: $webpath");

    var map = makeMapFromProxy(webpath);
    if (map == null) {
        return new Response.notFound(null);
    }
    var jdata = JSON.encode(map);
    return new Response.ok(jdata, headers: headers);
}


Map<String, dynamic> makeMapFromProxy(String webpath) {
    var map = new Map<String, dynamic>();

    ProxyItem proxy = fileSystem.getEntry(webpath);
    if (proxy == null) return null;

    map["id"] = webpath;

    if (proxy is DirectoryProxy) {
        map["type"] = "directory";
        map["children"] = proxy.children;
    } else if (proxy is FileProxy) {
        map["type"] = "file";
        map["size"] = proxy.size;
    } else {
        // error
        return null;
    }

    return map;
}
