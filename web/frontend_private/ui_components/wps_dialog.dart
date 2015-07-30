// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

class WpsDialog extends DialogVM {
  WpsProcess process;

  Map<String, _BaseTextInputVM> _fields = new Map<String, _BaseTextInputVM>();

  WpsDialog(RialtoFrontend frontend, String id, WpsProcess this.process) : super(frontend, id, skipStateTest: true) {
    for (var param in process.inputs) {
      _addParameter(param);
    }
  }

  void _addParameter(WpsProcessParam param) {
    FormElement form = querySelector("#" + id + "_formbody") as FormElement;
    assert(form != null);

    var div = new DivElement();
    div.classes.add("uk-form-row");
    form.children.add(div);

    LabelElement label = new LabelElement();
    label.htmlFor = id + "_" + param.name;
    label.text = "${param.name} (${WpsProcessParam.datatypeString(param.datatype)})";
    label.classes.add("uk-form-label");
    div.children.add(label);

    switch (param.datatype) {
      case WpsProcessParamDataType.double:
        _addParameter_double(param, div);
        break;
      case WpsProcessParamDataType.integer:
        _addParameter_integer(param, div);
        break;
      case WpsProcessParamDataType.string:
        _addParameter_string(param, div);
        break;
      case WpsProcessParamDataType.geopos2d:
        _addParameter_geopos2d(param, div);
        break;
      case WpsProcessParamDataType.geobox2d:
        _addParameter_geobox2d(param, div);
        break;
    }
  }

  void _addParameter_double(WpsProcessParam param, DivElement div) {
    InputElement input = _SingleTextInputVM.makeInputElement(id + "_" + param.name);
    div.children.add(input);

    _fields[param.name] = new DoubleInputVM(_frontend, id + "_" + param.name);
    _trackState(_fields[param.name]);
  }

  void _addParameter_integer(WpsProcessParam param, DivElement div) {
    InputElement input = _SingleTextInputVM.makeInputElement(id + "_" + param.name);
    div.children.add(input);

    _fields[param.name] = new IntInputVM(_frontend, id + "_" + param.name);
    _trackState(_fields[param.name]);
  }

  void _addParameter_string(WpsProcessParam param, DivElement div) {
    InputElement input = _SingleTextInputVM.makeInputElement(id + "_" + param.name);
    div.children.add(input);

    _fields[param.name] = new StringInputVM(_frontend, id + "_" + param.name, defaultValue: "string");
    _trackState(_fields[param.name]);
  }

  void _addParameter_geopos2d(WpsProcessParam param, DivElement div) {
    InputElement input = _SingleTextInputVM.makeInputElement(id + "_" + param.name);
    div.children.add(input);

    ButtonElement buttonElement = ButtonVM.makeButtonElement(id + "_" + param.name + "_button", "Set via UI");
    div.children.add(buttonElement);

    _fields[param.name] = new PositionInputVM(_frontend, id + "_" + param.name, this, new PositionString());
    _trackState(_fields[param.name]);
  }

  void _addParameter_geobox2d(WpsProcessParam param, DivElement div) {
    InputElement input = _SingleTextInputVM.makeInputElement(id + "_" + param.name);
    div.children.add(input);

    ButtonElement buttonElement = ButtonVM.makeButtonElement(id + "_" + param.name + "_button", "Set via UI");
    div.children.add(buttonElement);

    _fields[param.name] = new BoxInputVM(_frontend, id + "_" + param.name, this, new BoxString());
    _trackState(_fields[param.name]);
  }

  static void makeDialogShell(String name) {
    var dialogDiv = new DivElement();
    dialogDiv.id = name + "Dialog";
    dialogDiv.classes.add("uk-modal");

    querySelector("#documentBody").children.add(dialogDiv);

    var modalDiv = new DivElement();
    modalDiv.classes.add("uk-modal-dialog");
    dialogDiv.children.add(modalDiv);

    var headerDiv = new DivElement();
    headerDiv.classes.add("uk-modal-header");
    headerDiv.text = "WPS Process: " + name;
    modalDiv.children.add(headerDiv);

    var form = new FormElement();
    form.classes.add("uk-form");
    form.classes.add("uk-form-horizontal");
    form.id = name + "Dialog_formbody";
    modalDiv.children.add(form);

    var footerDiv = new DivElement();
    footerDiv.classes.add("uk-modal-footer");
    footerDiv.classes.add("uk-text-right");
    modalDiv.children.add(footerDiv);

    var button1 = new ButtonElement();
    button1.id = name + "Dialog_okay";
    button1.text = "Okay";
    button1.classes.add("uk-button");
    button1.classes.add("uk-modal-close");
    footerDiv.children.add(button1);

    var button2 = new ButtonElement();
    button2.id = name + "Dialog_cancel";
    button2.text = "Cancel";
    button2.classes.add("uk-button");
    button2.classes.add("uk-modal-close");
    footerDiv.children.add(button2);
  }

  @override
  void _show() {}

  @override
  void _hide() {
    RialtoBackend.log("running WPS process: ${process.name}");

    var inputs = new Map<String, dynamic>();
    for (WpsProcessParam param in process.inputs) {
      switch (param.datatype) {
        case WpsProcessParamDataType.double:
          inputs[param.name] = _fields[param.name].valueAs;
          break;
        case WpsProcessParamDataType.geobox2d:
          inputs[param.name] = _fields[param.name].valueAs;
          break;
        case WpsProcessParamDataType.geopos2d:
          inputs[param.name] = _fields[param.name].valueAs;
          break;
        case WpsProcessParamDataType.integer:
          inputs[param.name] = _fields[param.name].valueAs;
          break;
        case WpsProcessParamDataType.string:
          inputs[param.name] = _fields[param.name].valueAs;
          break;
      }
    }

    var yes = (WpsJob job) {
      _frontend.addWpsResultDialog(job);
    };

    var no = (WpsJob job) {
      String s = "WPS process failed: ${job.process.name}";
      if (job.outputs.containsKey("_stdout")) {
        var m = job.outputs['_stdout'];
        if (m is String && m.isNotEmpty) {
          s += "\n--------STDOUT--------\n$m";
        }
      }
      if (job.outputs.containsKey("_stderr")) {
        var m = job.outputs['_stderr'];
        if (m is String && m.isNotEmpty) {
          s += "\n--------STDERR--------\n$m";
        }
      }
      window.alert(s);
    };

    var time = (WpsJob job) {
      String s = "WPS process timed out: ${job.process.name}";
      window.alert(s);
    };

    _backend.wpsJobManager.execute(process, inputs, successHandler: yes, errorHandler: no, timeoutHandler: time);
  }
}
