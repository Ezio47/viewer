import 'package:start/start.dart';

void main() {
  start(host: "localhost", port: 8001).then((Server app) {

    app.static('/Users/mgerlek/work/dev/tuple/viewer/web');
    //app.static('/Users/mgerlek/work/dev/tuple/viewer/build/web');

    /*
    app.get('/hello/:name.:lastname?').listen((request) {
      request.response
        .header('Content-Type', 'text/html; charset=UTF-8')
        .send('Hello, ${request.param('name')} ${request.param('lastname')}');
    });

    app.ws('/socket').listen((socket) {
      socket.on('ping').listen((data) => socket.send('pong'));
      socket.on('pong').listen((data) => socket.close(1000, 'requested'));
    });
    */

  });
}
