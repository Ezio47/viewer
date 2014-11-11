library hub;

import 'dart:core';
import 'rb_render.dart';
import 'rb_settings.dart';
import 'rb_status.dart';

// thje global singleton
Hub hub = new Hub();

class Hub
{
  // the main Elements
  RbRender renderUI;
  RbSettings settingsUI;
  RbStatus statusUI;
  
  Hub()
  {
    return;
  }
  
  void addFile(String file)
  {
    settingsUI.doAddFile(file);
    renderUI.addGraph(file);
  }
  
  void removeFile(String file)
  {
    settingsUI.doRemoveFile(file);
    renderUI.removeGraph(file);
  }
  
  void showAxes(bool on)
  {
    renderUI.showAxes(on);
  }
  
  void mouseMoved(double x, double y)
  {
    statusUI.doMousePosition(x, y);
  }
}
