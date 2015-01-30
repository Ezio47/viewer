// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class Wps {
    final String _server;
    final int _port;
    final String _description;

    Hub _hub;
    Http.Client _client;

    Wps(String this._server, int this._port, [String this._description]) {
        _hub = Hub.root;

        _hub.events.WpsRequest.subscribe(_handleWpsRequest);

        _client = new BHttp.BrowserClient();

        Future<Capabilities> caps = doGetCapabilities();

        caps.then((_) => _client.close());
    }

    void _handleWpsRequest(WpsRequestData data) {
        log("WPS request: ${WpsRequestData.name[data.type]}, params=${data.params.length}");
    }

    Future<String> readAsync() {

        Completer c = new Completer<String>();

        String wps = "http://beta.sedac.ciesin.columbia.edu" +
                "" +
                "/wps/WebProcessingService?Request=DescribeProcess&Service=WPS&identifier=badfunctionnam";
        wps = Uri.encodeFull(wps);
        String proxy ="http://localhost:12345";

        var s = proxy + "/___" + wps;

        var h = { };

        var f = _client.get(s, headers:h).then((response) {
            //print(r.runtimeType);
            print("GOT*****************" + response.body);
            c.complete(response.body);
        }).catchError((e) {
            print(e);
            assert(false);
        });

        return c.future;
    }


    Future<Capabilities> doGetCapabilities() {
        var c = new Completer<Capabilities>();

        readAsync().then((String s) {
            print(s);
            c.complete(null);
        });

        return c.future;
    }
}


class Capabilities {
    Capabilities();
}


// http://beta.sedac.ciesin.columbia.edu/wps/WebProcessingService?Request=GetCapabilities&Service=WPS
// http://beta.sedac.ciesin.columbia.edu/wps/WebProcessingService?Request=DescribeProcess&Service=WPS&identifier=org.ciesin.gis.wps.algorithms.PopStats
// http://beta.sedac.ciesin.columbia.edu/wps/WebProcessingService?Request=DescribeProcess&Service=WPS&identifier=badfunctionname
