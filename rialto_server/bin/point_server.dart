// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.server;


class PointServer extends Server {

    PointServer(String server, int port, String dir) : super("Points", server, port, dir) {
        _handlerGET = webSocketHandler(_processPoints);
    }

    void _processPoints(websocket) {
        websocket.listen((webpath) {
            webpath = dir + webpath;
            print("server hears request for points for: $webpath");

            int totalBytes = 0;
            File f = new File(webpath);
            Stream s = f.openRead();
            s.listen((bytes) {
                websocket.add(bytes);
                //print("sent ${bytes.length} bytes");
                totalBytes += bytes.length;
            }, onDone: () {
                print("sent $totalBytes bytes");
                websocket.close();
            });
        });
    }
}
