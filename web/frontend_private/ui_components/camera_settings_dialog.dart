// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

class CameraSettingsDialog extends DialogVM {
  DoubleInputVM _longitude;
  DoubleInputVM _latitude;
  DoubleInputVM _height;
  DoubleInputVM _heading;
  DoubleInputVM _pitch;
  DoubleInputVM _roll;

  CameraSettingsDialog(RialtoFrontend frontend, String id) : super(frontend, id) {
    _longitude = new DoubleInputVM(_frontend, "cameraSettingsDialog_longitude", defaultValue: 0.0);
    _latitude = new DoubleInputVM(_frontend, "cameraSettingsDialog_latitude", defaultValue: 0.0);
    _height = new DoubleInputVM(_frontend, "cameraSettingsDialog_height", defaultValue: 15000000.0);
    _heading = new DoubleInputVM(_frontend, "cameraSettingsDialog_heading", defaultValue: 0.0);
    _pitch = new DoubleInputVM(_frontend, "cameraSettingsDialog_pitch", defaultValue: -90.0);
    _roll = new DoubleInputVM(_frontend, "cameraSettingsDialog_roll", defaultValue: 0.0);

    _trackState(_longitude);
    _trackState(_latitude);
    _trackState(_height);
    _trackState(_heading);
    _trackState(_pitch);
    _trackState(_roll);
  }

  @override
  void _show() {}

  @override
  void _hide() {
    var longitude = _longitude.valueAs;
    var latitude = _latitude.valueAs;
    var height = _height.valueAs;

    var heading = _heading.valueAs;
    var pitch = _pitch.valueAs;
    var roll = _roll.valueAs;

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
