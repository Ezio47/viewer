// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class Wps {
    final String _server;
    final int _port;
    final String _description;

    Hub _hub;

    Wps(String this._server, int this._port, [String this._description]) {
        _hub = Hub.root;

        _hub.events.WpsRequest.subscribe(_handleWpsRequest);
    }

    void _handleWpsRequest(WpsRequestData data) {
        log("WPS request: ${WpsRequestData.name[data.type]}, params=${data.params.length}");
    }
}
