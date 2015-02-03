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
    Future<ByteData> readAll(String webpath);
    Future<bool> readChunked(String path, int pointSize, FlushFunc handler);
}


class HttpComms extends Comms {
    Http.Client _client;

    HttpComms(String myserver) : super(myserver) {
        if (server.endsWith("/")) server = server.substring(0, server.length - 1);

        final int dimsPerPoint = 3;
        final int bytesPerDim = 4;
        final int bytesPerPoint = dimsPerPoint * bytesPerDim;

        final int pointsPerTile = 1024 * 64;
        final int bytesPerTile = pointsPerTile * bytesPerPoint;
    }

    @override
    void open() {
        _client = new BHttp.BrowserClient();
    }

    @override
    void close() {
        _client.close();
    }

    void _errf(Object o) // TODO
    {
        return;
    }

    @override
    Future<ByteData> readAll(String webpath) {

        Completer c = new Completer< ByteData>();

        assert(server.startsWith("ws:"));

        WebSocket ws = new WebSocket(server + "/points/");
        assert(ws != null);

        var buf = new ByteData(4096); // TODO: maxsize
        int bufIndex = 0;

        ws.onOpen.listen((_) {
            log("socket opened");

            ws.send(webpath); // {+file}
            ws.binaryType = "arraybuffer";
            ws.onMessage.listen((MessageEvent e) {
                ByteBuffer bytes = e.data;
                ByteData src = bytes.asByteData();
                for (int i=0; i<src.lengthInBytes; i++) {
                    final v = src.getUint8(i);
                    buf.setUint8(bufIndex, v);
                    ++bufIndex;
                }
            });
            ws.onClose.listen((_) {
                c.complete(buf);
                log("done");
            });
            ws.onError.listen((_) {
                assert(false); // TODO
            });
        });

        return c.future;
    }

    @override
    Future<bool> readChunked(String webpath, int pointSize, FlushFunc handler) {

        Completer c = new Completer();

        var readBuffer = new _ReadBuffer(pointSize * 1024 * 10);
        readBuffer.open(handler);

        assert(server.startsWith("ws:"));

        WebSocket ws = new WebSocket(server + "/points/");
        assert(ws != null);

        ws.onOpen.listen((_) {
            log("socket opened");

            ws.send(webpath); // {+file}
            ws.binaryType = "arraybuffer";
            ws.onMessage.listen((MessageEvent e) {
                ByteBuffer buf = e.data;
                readBuffer.push(buf);
            });
            ws.onClose.listen((_) {
                readBuffer.flush(force: true);
                readBuffer.close();
                c.complete(null);
                log("done");
            });
            ws.onError.listen((_) {
                assert(false); // TODO
            });
        });

        return c.future;
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
