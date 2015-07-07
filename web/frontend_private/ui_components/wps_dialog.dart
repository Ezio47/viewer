// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

class WpsDialog extends DialogVM {
  WpsProcess process;

  Map<String, TextInputVM> _fields = new Map<String, TextInputVM>();

  WpsDialog(RialtoFrontend frontend, String id, WpsProcess this.process)
      : super(frontend, id, ignoreStateChanging: true) {
    for (var param in process.inputs) {
      addParameter(param);
    }
  }

  void addParameter(WpsProcessParam param) {
    final idx = id.substring(1); // remove the '#'

    TableSectionElement tbody = querySelector(id + "_tbody") as TableSectionElement;

    TableRowElement trow = tbody.addRow();

    TableCellElement tcell = trow.addCell();

    LabelElement label = new LabelElement();
    label.htmlFor = idx + "_" + param.name;
    label.text = param.name;
    tcell.children.add(label);

    InputElement input = new InputElement();
    input.id = idx + "_" + param.name;
    input.type = "text";
    tcell.children.add(input);

    _fields[param.name] = new TextInputVM(_frontend, id + "_" + param.name, "");
    _register(_fields[param.name]);
  }

  static void makeDialogShell(String name) {
    var dialogDiv = new DivElement();
    dialogDiv.id = name + "Dialog";
    dialogDiv.classes.add("uk-modal");

    querySelector("#bodybodybody").children.add(dialogDiv);

    var modalDiv = new DivElement();
    modalDiv.classes.add("uk-modal-dialog");
    dialogDiv.children.add(modalDiv);

    var headerDiv = new DivElement();
    headerDiv.classes.add("uk-modal-header");
    headerDiv.text = "WPS Wizard for " + name;
    modalDiv.children.add(headerDiv);

    var form = new FormElement();
    form.classes.add("uk-form");
    modalDiv.children.add(headerDiv);

    var bodyDiv = new DivElement();
    modalDiv.children.add(bodyDiv);

    var table = new TableElement();
    bodyDiv.children.add(table);

    var tbody = table.createTBody();
    tbody.id = name + "Dialog_tbody";

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
    print("running wizard ${process.name}");

    var inputs = new Map<String, dynamic>();
    for (WpsProcessParam param in process.inputs) {
      switch (param.datatype) {
        case WpsProcessParamDataType.double:
          inputs[param.name] = _fields[param.name].valueAsDouble;
          break;
        case WpsProcessParamDataType.integer:
          inputs[param.name] = _fields[param.name].valueAsInt;
          break;
        case WpsProcessParamDataType.string:
          inputs[param.name] = _fields[param.name].value;
          break;
        default:
          RialtoBackend.error("invalid wps datatype");
      }
    }

    _backend.commands.wpsExecuteProcess(process, inputs);
  }
}
