// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend;

enum WpsProcessParamDataType { double, string, integer, position, box }

class WpsProcessParam {
  String name;
  WpsProcessParamDataType datatype;
  String description;

  WpsProcessParam(String this.name, WpsProcessParamDataType this.datatype, String this.description);

  static final _datatypeNames = {
    WpsProcessParamDataType.double: "double",
    WpsProcessParamDataType.string: "string",
    WpsProcessParamDataType.integer: "integer",
    WpsProcessParamDataType.position: "position",
    WpsProcessParamDataType.box: "box",
  };

  static String datatypeString(WpsProcessParamDataType datatype) {
    return _datatypeNames[datatype];
  }
}

class WpsProcess {
  WpsService service;
  String name;
  List<WpsProcessParam> inputs = new List<WpsProcessParam>();
  List<WpsProcessParam> outputs = new List<WpsProcessParam>();

  WpsProcess(WpsService this.service, String this.name);
}
