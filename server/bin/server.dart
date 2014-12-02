import 'dart:async';
import 'dart:io';
import 'dart:convert';

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
    fileSystem.dump();
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

String normalize(Request request) {
    assert(request.scriptName.startsWith("/file"));
    var path = request.scriptName.substring("/file".length);
    if (path.isEmpty) path = "/";

    assert(path.startsWith("/"));
    path = path.substring(1);
    return path;
}


var headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*, ",
    "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
    "Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept"
};


Future<Response> _getPoints(dynamic request) {
    final String path = normalize(request);
    print("==> $path");

    var fdata = new File('/Users/mgerlek/work/data/data.txt').readAsString();
    var resp = fdata.then((data) => new Response.ok(data, headers: headers));
    return resp;
}


Response _getFile(dynamic request) {
    final String path = normalize(request);
    print("==> $path");

    var map = makeMapFromProxy(path);
    if (map == null) {
        return new Response.notFound(null);
    }
    var jdata = JSON.encode(map);
    return new Response.ok(jdata, headers: headers);
}


Map<String,String> makeMapFromProxy(String path) {
    var map = new Map<String,String>();

    ProxyItem proxy = fileSystem.get(path);
    if (proxy == null) return null;

    if (proxy is DirectoryProxy) {
        map["children"] = proxy.children.length.toString();
    } else if (proxy is FileProxy) {
        map["size"] = proxy.size.toString();
    } else {
        // error
        return null;
    }

    return map;
}