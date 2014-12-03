library comms;

import 'dart:convert';
import 'dart:async';

import 'package:http/browser_client.dart' as bhttp;
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

import "proxy.dart";
import "utils.dart";


abstract class Comms {
    String server;
    Comms comms;

    Comms(String this.server);

    void open();
    void close();
    Future<String> readAsString(String path);
    Future<List<int>> readAsBytes(String path);
}


class HttpComms extends Comms {
    http.Client _client;

    HttpComms(String server) : super(server);

    @override
    void open() {
        _client = new bhttp.BrowserClient();
    }

    @override
    void close() {
        _client.close();
    }

    void _errf(Object o) // BUG
    {
        return;
    }

    @override
    Future<String> readAsString(String path) {

        String s = '${server}${path}';

        var f = _client.get(s).then((response) {
            //print(r.runtimeType);
            print(response.body);
            return response.body;
        }).catchError(_errf);

        return f;
    }

    @override
    Future<List<int>> readAsBytes(String path) {

        String s = '${server}${path}';

        var fbytes = _client.get(s).then((response) {
            print(response.body);
            return CryptoUtils.base64StringToBytes(response.body);
        }).catchError(_errf);

        return fbytes;
    }

    static void test() {
        var root = new ProxyFileSystem("http://localhost:12345");
    }
}


class FauxComms extends Comms {

    FauxComms(String server) : super(server);

    @override
    void open() {
    }

    @override
    void close() {
    }

    @override
    Future<List<int>> readAsBytes(String path) {
        throw new UnimplementedError();
    }

    @override
    Future<String> readAsString(String path) {
        var map;

        switch (path) {
            //case "http://www.example.com/":
            case "/":
                map = {
                    "type": "directory",
                    "dirs": ["/dir1", "/dir2"],
                    "files": ["/newcube.dat", "/oldcube.dat", "/terrain1.dat", "/terrain2.dat", "/terrain3.dat"]
                };
                break;
            case "/dir1":
                map = {
                    "type": "directory",
                    "dirs": [],
                    "files": [{
                            "name": "/dir1/random.dat",
                        }]
                };
                break;
            case "/dir2":
                map = {
                    "type": "directory",
                    "dirs": [],
                    "files": [{
                            "name": "/dir2/line.dat",
                            "dims": ["x", "y", "z"],
                            "size": 222
                        }]
                };
                break;
            case "/newcube.dat":
            case "/oldcube.dat":
            case "/terrain1.dat":
            case "/terrain2.dat":
            case "/terrain3.dat":
            case "/dir1/random.dat":
            case "/dir2/line.dat":
                map = {
                    "dims": ["x", "y", "z"],
                    "size": 1111
                };
                break;
            default:
                throw new Error();
        }

        return Utils.toFuture(JSON.encode(map));
    }

    static void test() {
        var root = new ProxyFileSystem("http://www.example.com/").root;
        for (var s in root.children) {
            assert(s != null);
            if (s is FileProxy) {
                (s as FileProxy).create();
            }
        }
        if (root.children != null) for (var s in root.children) {
            assert(s != null);
            if (s.children != null) for (var t in s.children) {
                assert(t != null);
                if (t is FileProxy) {
                    (t as FileProxy).create();
                }
            }
        }
        if (root.children != null) for (var s in root.children) {
            assert(s != null);
            if (s.children != null) for (var t in s.children) {
                assert(t != null);
                if (t.children != null) for (var u in t.children) {
                    assert(u != null);
                    if (u is FileProxy) {
                        (u as FileProxy).create();
                    }
                }
            }
        }
    }
}
