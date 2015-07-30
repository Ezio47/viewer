// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

class WpsResultDialog extends DialogVM {
  WpsJob job;

  Map<String, _BaseTextInputVM> _fields = new Map<String, _BaseTextInputVM>();

  WpsResultDialog(RialtoFrontend frontend, String id, WpsJob this.job)
      : super(frontend, id, hasCancelButton: false, skipStateTest: true) {
    for (var param in job.process.inputs) {
      _addParameter(param, job.inputs[param.name]);
    }
    for (var param in job.process.outputs) {
      if (param.name.startsWith('_')) continue;
      _addParameter(param, job.outputs[param.name]);
    }
  }

  void _addParameter(WpsProcessParam param, dynamic value) {
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
        _addParameter_double(param, div, value);
        break;
      case WpsProcessParamDataType.integer:
        _addParameter_integer(param, div, value);
        break;
      case WpsProcessParamDataType.string:
        _addParameter_string(param, div, value);
        break;
      case WpsProcessParamDataType.geopos2d:
        _addParameter_geopos2d(param, div, value);
        break;
      case WpsProcessParamDataType.geobox2d:
        _addParameter_geobox2d(param, div, value);
        break;
    }
  }

  void _addParameter_double(WpsProcessParam param, DivElement div, dynamic value) {
    InputElement input = _SingleTextInputVM.makeInputElement(id + "_" + param.name);
    input.disabled = true;
    div.children.add(input);

    _fields[param.name] = new DoubleInputVM(_frontend, id + "_" + param.name, defaultValue: value);
    _trackState(_fields[param.name]);
  }

  void _addParameter_integer(WpsProcessParam param, DivElement div, dynamic value) {
    InputElement input = _SingleTextInputVM.makeInputElement(id + "_" + param.name);
    input.disabled = true;
    div.children.add(input);

    _fields[param.name] = new IntInputVM(_frontend, id + "_" + param.name, defaultValue: value);
    _trackState(_fields[param.name]);
  }

  void _addParameter_string(WpsProcessParam param, DivElement div, dynamic value) {
    InputElement input = _SingleTextInputVM.makeInputElement(id + "_" + param.name);
    //input.disabled = true;
    div.children.add(input);

    ButtonElement buttonElement = ButtonVM.makeButtonElement(id + "_" + param.name + "_button", "Load layer");
    div.children.add(buttonElement);

    _fields[param.name] = new StringInputVM(_frontend, id + "_" + param.name, defaultValue: value);
    _trackState(_fields[param.name]);

    var clickHandler = () {
      RialtoBackend.log("load layer!");
      var thisjob = job;
      var thisparam = param;
      var thisvalue = value;
      var thisid = job.outputs['_id'];
      var uri = ConfigScript.defaultServers["data"].toString() + "/outputs/$thisid/${thisparam.name}.tif.tms";
      Map layerOptions = {
        "type": "tms_imagery",
        "url": uri,
        "gdal2Tiles": false,
        "maximumLevel": 12,
        //"alpha": 0.5
      };
      _backend.commands.addLayer("$thisid/${thisparam.name}", layerOptions);
    };
    new ButtonVM(_frontend, id + "_" + param.name + "_button", (e) => clickHandler());
  }

  void _addParameter_geopos2d(WpsProcessParam param, DivElement div, dynamic value) {
    InputElement input = _SingleTextInputVM.makeInputElement(id + "_" + param.name);
    input.disabled = true;
    div.children.add(input);

    ButtonElement buttonElement = ButtonVM.makeButtonElement(id + "_" + param.name + "_button", "Load layer");
    div.children.add(buttonElement);

    _fields[param.name] = new PositionInputVM(_frontend, id + "_" + param.name, this, value);
    _trackState(_fields[param.name]);
  }

  void _addParameter_geobox2d(WpsProcessParam param, DivElement div, dynamic value) {
    InputElement input = _SingleTextInputVM.makeInputElement(id + "_" + param.name);
    input.disabled = true;
    div.children.add(input);

    ButtonElement buttonElement = ButtonVM.makeButtonElement(id + "_" + param.name + "_button", "Load layer");
    div.children.add(buttonElement);

    _fields[param.name] = new BoxInputVM(_frontend, id + "_" + param.name, this, value);
    _trackState(_fields[param.name]);
  }

  static Element makeDialogShell(String name) {
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
    button1.text = "Close";
    button1.classes.add("uk-button");
    button1.classes.add("uk-modal-close");
    footerDiv.children.add(button1);

    return dialogDiv;
  }

  @override
  void _show() {}

  @override
  void _hide() {}
}
