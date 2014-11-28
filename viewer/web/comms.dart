library comms;

import 'dart:core';
import 'dart:convert';
import "proxy.dart";


// root = new PointCloudServer("http://faux");
// root.load(); // reads "/", now "list" is available
// root.sources has PCD("dir1") and PCF("tst1.las")
//
// pcd-dir1.load()  // reads "dir1", list avail
// pcd-dir1.sources now has PCF("2.las")
//

abstract class Comms {
    String server;
    Comms comms;

    Comms(String this.server);

    void open();
    void close();
    String read(String path);
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
    String read(String path) {
        var map;

        switch (path) {
            case "http://www.example.com/":
                map = {
                    "dirs": [{
                            "name": "dir1/"
                        }, {
                            "name": "dir2/"
                        }],
                    "files": [{
                            "name": "newcube.dat"
                        }, {
                            "name": "oldcube.dat"
                        }, {
                            "name": "terrain1.dat",
                            "numpoints": 512*512
                        }, {
                            "name": "terrain2.dat",
                            "numpoints": 512*512
                        }, {
                            "name": "terrain3.dat",
                            "numpoints": 512*512
                        }]
                };
                break;
            case "http://www.example.com/dir1/":
                map = {
                    "dirs": [],
                    "files": [{
                            "name": "random.dat",
                            "dims": ["x", "y", "z"],
                            "numpoints": 1111
                        }]
                };
                break;
            case "http://www.example.com/dir2/":
                map = {
                    "dirs": [],
                    "files": [{
                            "name": "line.dat",
                            "dims": ["x", "y", "z"],
                            "numpoints": 222
                        }]
                };
                break;
            default:
                throw new Error();
        }

        return JSON.encode(map);
    }

    static void test() {
        var root = new ServerProxy("http://www.example.com/");
        root.load();
        for (var s in root.sources) {
            assert(s != null);
            s.load();
            if (s is FileProxy) {
                (s as FileProxy).create();
            }
        }
        if (root.sources != null) for (var s in root.sources) {
            assert(s != null);
            if (s.sources != null) for (var t in s.sources) {
                assert(t != null);
                t.load();
                if (t is FileProxy) {
                    (t as FileProxy).create();
                }
            }
        }
        if (root.sources != null) for (var s in root.sources) {
            assert(s != null);
            if (s.sources != null) for (var t in s.sources) {
                assert(t != null);
                if (t.sources != null) for (var u in t.sources) {
                    assert(u != null);
                    u.load();
                    if (u is FileProxy) {
                        (u as FileProxy).create();
                    }
                }
            }
        }
    }
}
