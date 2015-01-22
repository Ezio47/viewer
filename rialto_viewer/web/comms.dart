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
    _ReadBuffer _readBuffer;

    HttpComms(String myserver) : super(myserver) {
        if (server.endsWith("/")) server = server.substring(0, server.length - 1);

        final int bytesPerPoint = 3 * 4 /* + 4*4 */;
        final int pointsPerTile = 1024 * 64;
        _readBuffer = new _ReadBuffer(bytesPerPoint * pointsPerTile);
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

        _readBuffer.open(handler);

        WebSocket ws = new WebSocket('ws://localhost:12345/points/');
        ws.onOpen.listen((_) {
            print("socket opened");

            ws.send(webpath); // {+file}
            ws.binaryType = "arraybuffer";
            ws.onMessage.listen((MessageEvent e) {
                ByteBuffer buf = e.data;
                _readBuffer.push(buf);
            });
            ws.onClose.listen((_) {
                _readBuffer.flush(force: true);
                _readBuffer.close();
                c.complete(null);
                log("done");
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
    int _maxsize;
    Uint8List _buffer;
    int _used;
    FlushFunc _flushfunc;

    _ReadBuffer(int this._maxsize);

    void open(FlushFunc f) {
        _buffer = null;
        _used = 0;
        _flushfunc = f;
    }

    void push(ByteBuffer src) {
        int p = 0;
        while (p < src.lengthInBytes) {
            int amt = min(_maxsize - _used, src.lengthInBytes - p);
            append(src, p, amt);
            flush();
            p += amt;
        }
    }

    void close() {
        flush(force: true);
        _buffer = null;
        _used = 0;
        _flushfunc = null;
    }

    void append(ByteBuffer src, int p, int amt) {
        Uint8List src8 = new Uint8List.view(src);
        assert(_used + amt <= _maxsize);
        if (_buffer == null) {
            assert(_used == 0);
            _buffer = new Uint8List(_maxsize);
        }
        for (int i = p; i < p + amt; i++) {
            _buffer[_used] = src8[i];
            _used++;
        }
    }

    void flush({bool force: false}) {
        if (_buffer == null || _used == 0) return;
        if (_used < _maxsize && !force) return;
        _flushfunc(_buffer.buffer, _used);
        _buffer = null;
        _used = 0;
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
