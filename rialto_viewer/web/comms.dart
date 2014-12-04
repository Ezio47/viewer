part of rialto.viewer;



abstract class Comms {
    String server;
    Comms comms;

    Comms(String this.server);

    void open();
    void close();
    Future<String> readAsString(String path);
    Future<Float32List> readAsBytes(String path);
}


class HttpComms extends Comms {
    http.Client _client;

    HttpComms(String myserver) : super(myserver) {
        if (server.endsWith("/")) server = server.substring(0, server.length - 1);
    }

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
    Future<Float32List> readAsBytes(String webpath) {
        Completer c = new Completer();

        WebSocket ws = new WebSocket('ws://localhost:12345/points/');
        ws.onOpen.listen((_) {
            print("socket opened");

            var bufs = new List<ByteBuffer>();
            int siz = 0;

            ws.send(webpath); // {+file}
            ws.binaryType = "arraybuffer";
            ws.onMessage.listen((MessageEvent e) {
                ByteBuffer buf = e.data;
                bufs.add(buf);
                print("read ${buf.lengthInBytes} bytes");
                siz += buf.lengthInBytes;
            });
            ws.onClose.listen((_) {
                var bigbuf = new Float32List(siz ~/ 4);
                int j = 0;
                for (var buf in bufs) {
                    for (int i = 0; i < buf.lengthInBytes ~/ 4; i++) {
                        Float32List tmp = new Float32List.view(buf);
                        bigbuf[j] = tmp[i];
                        j++;
                    }
                }
                assert(j * 4 == siz);
                c.complete(bigbuf);
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


class FauxComms extends Comms {

    FauxComms(String server) : super(server);

    @override
    void open() {
    }

    @override
    void close() {
    }

    @override
    Future<Float32List> readAsBytes(String path) {
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
