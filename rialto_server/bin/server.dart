// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

library rialto.server;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf_exception_response/exception_response.dart';


part 'main_server.dart';
part 'point_server.dart';


abstract class Server {
    final String type;
    String dir;
    String server;
    int port;

    Function _handlerGET;

    final headers = {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*, ",
        "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
        "Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept"
    };

    Server(String this.type, String this.server, int this.port, String this.dir) {
        _handlerGET = (_) { assert(false); };
    }

    void run() {
        var router = shelf_route.router()..get('/{+file}', _handlerGET, middleware: logRequests());

        var httpHandler =
                const Pipeline().addMiddleware(logRequests()).addMiddleware(exceptionResponse()).addHandler(router.handler);

        Future<HttpServer> fserver = shelf_io.serve(httpHandler, server, port).then((s) {
            print('$type server started at http://${s.address.host}:${s.port}');
            shelf_route.printRoutes(router);
        });

    }
}


void main(List<String> args) {
    var parser = new ArgParser()
            ..addOption('mode', abbr: 'm', allowed: ['main', 'points'])
            ..addOption('server', abbr: 's', defaultsTo: 'localhost')
            ..addOption('port', abbr: 'p', defaultsTo: '12345')
            ..addOption('dir', abbr: 'd', defaultsTo: '.');

    var usage = (String s) {
        print('Usage error: $s');
        print(parser.usage);
        exit(1);
    };

    var results;
    try {
        results = parser.parse(args);
    } on FormatException catch (e) {
        usage(e.message);
    } catch (e) {
        usage(e);
    }

    final mode = results['mode'];
    final server = results['server'];
    final port = int.parse(results['port'], onError: ((s) {
        usage(s);
    }));
    final dir = results['dir'];

    if (results['mode'] == null) {
        usage('--mode required');
    }

    Server s;

    switch (results['mode']) {
        case 'main':
            s = new MainServer(server, port, dir);
            break;
        case 'points':
            s = new PointServer(server, port, dir);
            break;
    }

    s.run();
}
