library rialto.server;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_exception_response/exception_response.dart';
import 'package:watcher/watcher.dart';
import 'package:path/path.dart' as path;

part 'proxy.dart';


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

    var router = shelf_route.router()
            ..get('/', (_) => new Response.notFound(null), middleware: logRequests())
            ..get('/points', webSocketHandler(_getPoints), middleware: logRequests())
            ..get('/file', _getFile, middleware: logRequests())
            ..get('/file/{+file}', _getFile, middleware: logRequests());

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

        ProxyItem proxy = fileSystem.getEntry(webpath);
        if (proxy is! FileProxy) {
            return; // BUG error
        }
        FileProxy fileProxy = proxy as FileProxy;

        String fspath = fileProxy.file.path;
        String fspath2 = fileSystem.toFsPath(webpath);
        assert(fspath == fspath2);

        File f = fileProxy.file;
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
    final String webpath = normalize(request, "/file");
    // print("requesting file from: $webpath");

    var map = makeMapFromProxy(webpath);
    if (map == null) {
        return new Response.notFound(null, headers: headers);
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
        map["dirs"] = [];
        map["files"] = [];
        for (var childWebPath in proxy.children) {
            ProxyItem childProxy = fileSystem.getEntry(childWebPath);
            assert(childProxy != null);
            if (childProxy is DirectoryProxy) {
                map["dirs"].add(childWebPath);
            } else if (childProxy is FileProxy) {
                map["files"].add(childWebPath);
            } else {
                return null; // error
            }
        }
    } else if (proxy is FileProxy) {
        map["type"] = "file";
        map["size"] = proxy.size;
    } else {
        // error
        return null;
    }

    return map;
}
