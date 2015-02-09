// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;



class WebSocketReader {
    String _server;
    Http.Client _client;

    WebSocketReader(String this._server) {
        if (_server.endsWith("/")) _server = _server.substring(0, _server.length - 1);

        if (!_server.startsWith("ws:")) {
            Hub.error("Invalid name for server: should use 'ws:' protocol");
        }
    }

    void open() {
        _client = new BHttp.BrowserClient();
    }

    void close() {
        _client.close();
    }

    Future<ByteData> readAll(String webpath) {

        Completer c = new Completer<ByteData>();

        WebSocket ws = new WebSocket(_server + "/points/");
        assert(ws != null);

        ByteData buf;
        int bufIndex = 0;

        ws.onOpen.listen((_) {
            log("socket opened");

            ws.send(webpath); // {+file}
            ws.binaryType = "arraybuffer";
            ws.onMessage.listen((MessageEvent e) {
                ByteBuffer bytes = e.data;
                ByteData src = bytes.asByteData();
                if (buf == null) {
                    buf = new ByteData(src.lengthInBytes);
                    bufIndex = 0;
                } else {
                    var tmp = new ByteData(buf.lengthInBytes + src.lengthInBytes);
                    for (int i = 0; i < buf.lengthInBytes; i++) {
                        tmp.setUint8(i, buf.getUint8(i));
                    }
                    bufIndex = buf.lengthInBytes;
                    buf = tmp;
                }
                for (int i = 0; i < src.lengthInBytes; i++) {
                    final v = src.getUint8(i);
                    buf.setUint8(bufIndex, v);
                    ++bufIndex;
                }
            });
            ws.onClose.listen((_) {
                c.complete(buf);
                log("done");
            });
            ws.onError.listen((e) {
                Hub.error("error reading socket: $e");
            });
        });

        return c.future;
    }

    Future<String> readAllText(String webpath) {

        Completer c = new Completer<String>();

        WebSocket ws = new WebSocket(_server + "/points/");
        assert(ws != null);

        var buf = "";

        ws.onOpen.listen((_) {
            log("socket opened");

            ws.send(webpath); // {+file}
            ws.binaryType = "arraybuffer";
            ws.onMessage.listen((MessageEvent e) {
                ByteBuffer bytes = e.data;
                ByteData src = bytes.asByteData();
                var json = UTF8.decoder.convert(bytes.asUint8List());
                buf += json;
            });
            ws.onClose.listen((_) {
                c.complete(buf);
                log("done");
            });
            ws.onError.listen((e) {
                Hub.error("error reading socket: $e");
            });
        });

        return c.future;
    }

    Future<bool> readChunked(String webpath, int numBytes, _BufferFunction handler) {

        Completer c = new Completer();

        WebSocket ws = new WebSocket(_server + "/points/");
        assert(ws != null);

        var buffer = new _BufferController(numBytes, handler);

        ws.onOpen.listen((_) {
            log("socket opened");

            ws.send(webpath);
            ws.binaryType = "arraybuffer";
            ws.onMessage.listen((MessageEvent e) {
                buffer.add(e.data);
            });
            ws.onClose.listen((_) {
                buffer.close();
                c.complete(true);
                log("done");
            });
            ws.onError.listen((_) {
                Hub.error("error reading socket");
                c.complete(false);
            });
        });

        return c.future;
    }
}


class _BufferController {
    StreamController _controller;
    int _size;
    _BufferFunction _handler;

    _BufferController(int this._size, _BufferFunction this._handler) {

        _controller = new StreamController();

        _Buffer buffy = new _Buffer(_size, _handler);

        _controller.stream.listen(
                ((ByteBuffer b) => buffy.push(b)),
                onError: ((e) => throw new StateError("internal buffering error: $e")),
                onDone: (() => buffy.close()));
    }

    void add(e) {
        _controller.add(e);
    }

    void close() {
        _controller.close();
    }
}


typedef void _BufferFunction(ByteData);

class _Buffer {
    final int _size;
    final _BufferFunction _handler;
    int _used;
    Uint8List _buffer;

    _Buffer(int this._size, _BufferFunction this._handler)
            : _buffer = null,
              _used = 0;

    void push(ByteBuffer src) {
        int p = 0;
        while (p < src.lengthInBytes) {
            int amt = min(_size - _used, src.lengthInBytes - p);
            _append(src, p, amt);
            _flush();
            p += amt;
        }
    }

    void close() {
        _flush(force: true);
    }

    void _append(ByteBuffer src, int p, int amt) {
        Uint8List src8 = new Uint8List.view(src);
        assert(_used + amt <= _size);
        if (_buffer == null) {
            assert(_used == 0);
            _buffer = new Uint8List(_size);
        }
        for (int i = p; i < p + amt; i++) {
            _buffer[_used] = src8[i];
            _used++;
        }
    }

    void _flush({bool force: false}) {
        if (_buffer == null || _used == 0) return;
        if (_used < _size && !force) return;

        var b = new ByteData.view(_buffer.buffer, 0, _used);
        assert(b.lengthInBytes == _used);

        _handler(b);

        _buffer = null;
        _used = 0;
    }
}
