library hub;


import 'dart:core';
import 'dart:html';
import 'elements/render_element.dart';
import 'elements/settings_element.dart';
import 'elements/status_element.dart';
import 'renderer.dart';
import 'cloud_generator.dart';
import 'point_cloud.dart';


// thje global singleton
Hub hub = new Hub();

class Hub
{
  // the big, public, singleton components
  RenderElement renderUI;
  SettingsElement settingsUI;
  StatusElement statusUI;
  Element canvas;
  Renderer renderer;

  // private
  Map<String, PointCloud> _pointclouds = new Map();


  Hub()
  {
    return;
  }


  void doColorizeFile(String file)
  {
    renderer.unsetCloud();

    PointCloud cloud = _pointclouds[file];
    assert(cloud != null);

    cloud.colorize();

    renderer.setCloud(cloud);
  }


  void doAddFile(String file)
  {
    settingsUI.doAddFile(file);

    var data = CloudGenerator.generate(file);
    var cloud = new PointCloud(data);

    _pointclouds[file] = cloud;

    statusUI.minx = cloud.low.x;
    statusUI.maxx = cloud.high.x;
    statusUI.miny = cloud.low.y;
    statusUI.maxy = cloud.high.y;
    statusUI.minz = cloud.low.z;
    statusUI.maxz = cloud.high.z;

    // we don't make the renderer until we have to
    if (renderer == null)
    {
      renderer = new Renderer(canvas);
      renderer.init();
      renderer.animate(0);
    }

    renderer.setCloud(cloud);
  }


  void doRemoveFile(String file)
  {
    settingsUI.doRemoveFile(file);
    _pointclouds.remove(file);

    renderer.unsetCloud();
  }


  void doToggleAxes(bool on) => renderer.toggleAxesDisplay(on);

  void doToggleBbox(bool on) => renderer.toggleBboxDisplay(on);


  void doMouseMoved()
  {
    statusUI.mousePositionX = renderer.mouseX;
    statusUI.mousePositionY = renderer.mouseY;
  }
}
