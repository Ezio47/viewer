// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class Wps {
    String server;
    int port;
    String description;

    Wps(String this.server, int this.port, [String this.description]);
}
