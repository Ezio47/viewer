// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


abstract class Comms {
    String server;
    Comms comms;

    Comms(String this.server);

    void open();
    void close();
    Future<String> readAsString(String path);
    Future<bool> readAsBytes(String path, FlushFunc handler);
}


class HttpComms extends Comms {
    Http.Client _client;

    HttpComms(String myserver) : super(myserver) {
        if (server.endsWith("/")) server = server.substring(0, server.length - 1);
    }

    @override
    void open() {
        _client = new BHttp.BrowserClient();
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
    Future<String> readAsString(String webpath) {

        String s = '${server}/file${webpath}';

        var f = _client.get(s).then((response) {
            //print(r.runtimeType);
            //print(response.body);
            return response.body;
        }).catchError(_errf);

        return f;
    }

    @override
    Future<bool> readAsBytes(String webpath, FlushFunc handler) {
        Completer c = new Completer();

        _ReadBuffer readBuffer = new _ReadBuffer(3*4*1024*10, handler);

        WebSocket ws = new WebSocket('ws://localhost:12345/points/');
        ws.onOpen.listen((_) {
            print("socket opened");

            ws.send(webpath); // {+file}
            ws.binaryType = "arraybuffer";
            ws.onMessage.listen((MessageEvent e) {
                ByteBuffer buf = e.data;
                readBuffer.push(buf);
            });
            ws.onClose.listen((_) {
                readBuffer.flush(force:true);
                c.complete(null);
            });
            ws.onError.listen((_) {
                assert(false);
            });
        });

        return c.future;
    }

    static void test() {
        var root = new ProxyFileSystem("http://localhost:12345");
    }
}

typedef FlushFunc(ByteBuffer, used);

class _ReadBuffer {
    int maxsize;
    Uint8List buf;
    int used;
    FlushFunc flushfunc;

    _ReadBuffer(int this.maxsize, FlushFunc this.flushfunc) {
        open();
    }

    void open() {
        buf = null;
        used = 0;
    }

    void push(ByteBuffer src) {
        int p = 0;
        while (p < src.lengthInBytes) {
            int amt = min(maxsize - used, src.lengthInBytes  - p);
            append(src, p, amt);
            flush();
            p += amt;
        }
    }

    void close() {
        flush(force:true);
    }

    void append(ByteBuffer src, int p, int amt) {
        Uint8List src8 = new Uint8List.view(src);
        assert(used + amt <= maxsize);
        if (buf == null) {
            assert(used == 0);
            buf = new Uint8List(maxsize);
        }
        for (int i=p; i<p+amt; i++) {
            buf[used] = src8[i];
            used++;
        }
    }

    void flush({bool force:false}) {
        if (buf == null || used == 0) return;
        if (used < maxsize && !force) return;
        flushfunc(buf.buffer, used);
        buf = null;
        used = 0;
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
    Future<bool> readAsBytes(String path, FlushFunc handler) {
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
                    "files": ["/dir1/random.dat"]
                };
                break;
            case "/dir2":
                map = {
                    "type": "directory",
                    "dirs": [],
                    "files": ["/dir2/line.dat"]
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
}
