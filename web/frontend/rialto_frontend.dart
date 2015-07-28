// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend;

/// code-behind for the index.html file
///
/// This class implements the functionality in Rialto's index.html file.
///
/// It is considered a "client" of the Rialto library, and so it should only access the viewer's
/// public interfaces.
class RialtoFrontend {
  RialtoBackend backend;
  Element _mouseCoords;

  ViewModeCode viewMode = ViewModeCode.mode3D;

  Element _textWpsJobStatus;

  RialtoFrontend() {
    backend = new RialtoBackend();

    querySelector("#homeWorldButton").onClick.listen((ev) => backend.commands.zoomToWorld());
    querySelector("#homeDataButton").onClick.listen((ev) => backend.commands.zoomToLayer(null));

    querySelector("#wpsTestButton").onClick.listen((ev) => backend.commands.testWps());
    querySelector("#viewshedCircleButton").onClick.listen((ev) => backend.commands.createViewshedCircle());
    querySelector("#viewshedComputeButton").onClick.listen((ev) => backend.commands.computeViewshed());

    querySelector("#linearMeasurementButton").onClick.listen((ev) => backend.commands.computeLinearMeasurement());
    querySelector("#areaMeasurementButton").onClick.listen((ev) => backend.commands.computeAreaMeasurement());

    querySelector("#dropPinButton").onClick.listen((ev) => backend.commands.dropPin());

    querySelector("#drawExtentButton").onClick.listen((ev) => backend.commands.drawExtent());

    var modeButton2D = querySelector("#modeButton2D");
    var modeButton25D = querySelector("#modeButton25D");
    var modeButton3D = querySelector("#modeButton3D");
    modeButton2D.onClick.listen((ev) => backend.commands.setViewMode(new ViewModeData(ViewModeCode.mode2D)));
    modeButton25D.onClick.listen((ev) => backend.commands.setViewMode(new ViewModeData(ViewModeCode.mode25D)));
    modeButton3D.onClick.listen((ev) => backend.commands.setViewMode(new ViewModeData(ViewModeCode.mode3D)));

    new LoadUrlDialog(this, "loadUrlDialog");
    new LoadScriptDialog(this, "loadScriptDialog");
    new LayerCustomizationDialog(this, "layerCustomizationDialog");
    new LayerInfoDialog(this, "layerInfoDialog");
    new CameraSettingsDialog(this, "cameraSettingsDialog");
    new AdvancedSettingsDialog(this, "advancedSettingsDialog");

    new AboutDialog(this, "aboutRialtoDialog");
    new AboutDialog(this, "aboutCesiumDialog");
    new AboutDialog(this, "wpsStatusDialog");
    new AboutDialog(this, "logDialog");

    _mouseCoords = querySelector("#textMouseCoords");
    backend.events.MouseMove.subscribe(_handleUpdateCoords);

    _textWpsJobStatus = querySelector("#wpsStatusDialog_open");
    _handleWpsJobUpdate();
    backend.events.WpsJobUpdate.subscribe((_) => _handleWpsJobUpdate());

    ButtonElement clearLogButton = querySelector("#logDialog_clear");
    clearLogButton.onClick.listen((_) {
      var e = querySelector("#logDialog_body");
      if (e != null) {
        e.text = "";
      }
    });
  }

  void addWpsControls() {
    WpsService wps = backend.wpsService;
    if (wps == null) return;

    for (WpsProcess process in wps.processes.values) {
      _addWpsMenuItem(process.name);
      _addWpsProcessDialog(process.name);
    }
  }

  void _addWpsMenuItem(String processName) {
    var name = processName.substring(3); // exclude the "py:" part

    var anchor = new AnchorElement();
    anchor.id = name + "Dialog_open";
    anchor.text = name;

    var list = new LIElement();
    list.classes.add("uk-active");
    list.children.add(anchor);

    UListElement menu = querySelector("#wpsMenu");
    menu.children.add(list);
  }

  void _addWpsProcessDialog(String processName) {
    var name = processName.substring(3); // exclude the "py:" part

    // create the <dialog> html
    WpsDialog.makeDialogShell(name);

    // populate the shell
    new WpsDialog(this, name + "Dialog", backend.wpsService.processes[processName]);
  }

  void addWpsResultDialog(WpsJob job) {
    var name = job.process.name.substring(3); // exclude the "py:" part

    name += "Result";

    // create the <dialog> html
    WpsResultDialog.makeDialogShell(name);

    // populate the shell
    var dlg = new WpsResultDialog(this, name + "Dialog", job);

    dlg.show();
  }

  String get viewModeString => "Mode / ${ViewModeData.name[viewMode]}";

  void _handleUpdateCoords(MouseData d) {
    var v = backend.cesium.getMouseCoordinates(d.x, d.y);
    if (v == null) return;

    final precision = backend.displayPrecision;
    final double lon = v.longitude;
    final double lat = v.latitude;
    String s = "(${lon.toStringAsFixed(precision)}, ${lat.toStringAsFixed(precision)})";

    _mouseCoords.text = s;
  }

  void _handleWpsJobUpdate() {
    final int numActive = backend.wpsJobManager.numActive;

    if (numActive < 0) {
      throw new ArgumentError("invalid WPS request count");
    }

    if (numActive == 0) {
      if (!_textWpsJobStatus.classes.contains("uk-text-muted")) {
        _textWpsJobStatus.classes.add("uk-text-muted");
      }
    } else {
      if (_textWpsJobStatus.classes.contains("uk-text-muted")) {
        _textWpsJobStatus.classes.remove("uk-text-muted");
      }
    }

    _textWpsJobStatus.text = "Active jobs: ${backend.wpsJobManager.numActive}";

    String s = "";
    s += "Job count: ${backend.wpsJobManager.map.length}\n";

    backend.wpsJobManager.map.keys.forEach((id) => s += "\n----\n" + backend.wpsJobManager.map[id].dump());
    querySelector("#wpsStatusDialog_body").text = s;
  }
}
