// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend;

enum WpsProcessParamDataType { double, string, integer }

class WpsProcessParam {
  String name;
  WpsProcessParamDataType datatype;

  WpsProcessParam(String this.name, WpsProcessParamDataType this.datatype);
}

class WpsProcess {
  WpsService service;
  String name;
  List<WpsProcessParam> inputs = new List<WpsProcessParam>();
  List<WpsProcessParam> outputs = new List<WpsProcessParam>();

  WpsProcess(WpsService this.service, String this.name);
}
