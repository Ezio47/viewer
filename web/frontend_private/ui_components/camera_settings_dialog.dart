// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

class CameraSettingsDialog extends DialogVM {
  TextInputVM _longitude;
  TextInputVM _latitude;
  TextInputVM _height;
  TextInputVM _heading;
  TextInputVM _pitch;
  TextInputVM _roll;

  CameraSettingsDialog(RialtoFrontend frontend, String id) : super(frontend, id) {
    _longitude = new TextInputVM(_frontend, "#cameraSettingsDialog_longitude", "0.0");
    _latitude = new TextInputVM(_frontend, "#cameraSettingsDialog_latitude", "0.0");
    _height = new TextInputVM(_frontend, "#cameraSettingsDialog_height", "15000000.0");
    _heading = new TextInputVM(_frontend, "#cameraSettingsDialog_heading", "0.0");
    _pitch = new TextInputVM(_frontend, "#cameraSettingsDialog_pitch", "-90.0");
    _roll = new TextInputVM(_frontend, "#cameraSettingsDialog_roll", "0.0");

    register(_longitude);
    register(_latitude);
    register(_height);
    register(_heading);
    register(_pitch);
    register(_roll);
  }

  @override
  void _show() {}

  @override
  void _hide() {
    var longitude = _longitude.valueAsDouble;
    var latitude = _latitude.valueAsDouble;
    var height = _height.valueAsDouble;

    var heading = _heading.valueAsDouble;
    var pitch = _pitch.valueAsDouble;
    var roll = _roll.valueAsDouble;

    final eyeOkay = (longitude != null && latitude != null && height != null);
    if (!eyeOkay) {
      RialtoBackend.error("Invalid camera settings (camera position)");
      return;
    }

    final targetOkay = (heading != null && pitch != null && roll != null);
    if (!targetOkay) {
      RialtoBackend.error("Invalid camera settings (heading/pitch/roll)");
      return;
    }

    _backend.commands.zoomToCustom(longitude, latitude, height, heading, pitch, roll);
  }
}
