// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:args/args.dart';


class Server {
    String server;
    int port;
    String rootDir;

    static const FILE = '/file';
    static const PROXY = '/proxy';

    final headers = {
        // "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
        "Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept"
    };

    Server(String this.server, int this.port, String this.rootDir);

    void run() {
        log("Listening on $server:$port for directory $rootDir");

        HttpServer.bind(server, port).then((server) {
            server.listen(_handler);
        });
    }

    void log(Object o) {
        DateTime now = new DateTime.now();
        if (o is HttpRequest) {
            print("REQU  $now  ${o.method}  ${o.uri}");
        } else if (o is HttpResponse) {
            print("RESP $now  ${o.statusCode}");
        } else {
            print("INFO  $now  $o");
        }
    }

    void fail(HttpRequest request) {
        request.response.statusCode = HttpStatus.NOT_FOUND;
        request.response.write("[${HttpStatus.NOT_FOUND}] Not found.");
        request.response.close();
    }

    void _handler(HttpRequest request) {
        log(request);

        headers.forEach((k, v) => request.response.headers.set(k, v));

        _handlerInner(request);

        log(request.response);
    }

    void _handlerInner(HttpRequest request) {

        if (request.method != 'GET') {
            fail(request);
            return;
        }

        String path = request.uri.path;

        if (path.startsWith(FILE)) {
            _fileHandler(request, path.substring(FILE.length));
            return;
        }

        if (path.startsWith(PROXY)) {
            String query = request.uri.query;
            query = Uri.decodeComponent(query);
            Uri uri = Uri.parse(query);
            _proxyHandler(request, uri);
            return;
        }

        fail(request);
    }

    void _fileHandler(HttpRequest request, String path) {

        var filename = rootDir + path;

        //log("request for $filename");

        File file = null;

        try {
            file = new File(filename);
        } catch (e) {
            //log("Unable to open file: $filename");
            //log("Exception: $e");
            fail(request);
            return;
        }

        if (!file.existsSync()) {
            //log("Unable to read file: $filename");
            fail(request);
            return;
        }

        request.response.statusCode = HttpStatus.OK;
        request.response.addStream(file.openRead()).then((_) {
            //log("added bytes for $filename");
            request.response.flush().then((_) {
                request.response.close();
            });
        });

        return;
    }

    void _proxyHandler(HttpRequest request, Uri uri) {
        //log("proxy request for: $uri");

        getter(uri).then((s) {
            request.response.statusCode = HttpStatus.OK;
            request.response.write(s);
            request.response.close();
        });
    }

    Future getter(uri) {
        var c = new Completer<String>();

        List<int> retList = [];
        String retString = "";

        var cli = new HttpClient();

        cli.getUrl(uri).then((HttpClientRequest request) {

            headers.forEach((k, v) => request.headers.set(k, v));

            return request.close();

        }).then((HttpClientResponse response) {
            //log(response.statusCode);
            //log(response.headers);

            if (response.headers.contentType == ContentType.BINARY ||
                    response.headers.contentType.toString() == "image/jpeg") {
                response.listen((contents) {
                    retList.addAll(contents);
                }, onDone: () {
                    c.complete(retList);
                });
            } else if (response.headers.contentType == ContentType.HTML ||
                    response.headers.contentType == ContentType.TEXT ||
                    response.headers.contentType == ContentType.JSON ||
                    response.headers.contentType.toString() == "text/xml") { // TODO: hack
                response.transform(UTF8.decoder).listen((contents) {
                    retString += contents;
                }, onDone: () {
                    c.complete(retString);
                });
            } else {
                log("*** UNKNOWN CONTENT TYPE: -${response.headers.contentType.toString()}-");
                exit(99);
            }
        });

        return c.future;
    }
}


void main(List<String> args) {
    var parser = new ArgParser()
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

    final server = results['server'];
    final port = int.parse(results['port'], onError: ((s) {
        usage(s);
    }));
    final dir = results['dir'];

    Server s = new Server(server, port, dir);

    s.run();
}
