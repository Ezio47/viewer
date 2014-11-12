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
    renderer.removeCloud();

    PointCloud cloud = _pointclouds[file];
    assert(cloud != null);

    cloud.colorize();

    renderer.addCloud(cloud);
  }


  void doAddFile(String file)
  {
    settingsUI.doAddFile(file);

    var data = CloudGenerator.generate(file);
    var cloud = new PointCloud(data);

    _pointclouds[file] = cloud;

    statusUI.minx = cloud.minx;
    statusUI.maxx = cloud.maxx;
    statusUI.miny = cloud.miny;
    statusUI.maxy = cloud.maxy;
    statusUI.minz = cloud.minz;
    statusUI.maxz = cloud.maxz;

    // we don't make the renderer until we have to
    if (renderer == null)
    {
      renderer = new Renderer(canvas);
      renderer.init();
      renderer.animate(0);
    }

    renderer.addCloud(cloud);
  }


  void doRemoveFile(String file)
  {
    settingsUI.doRemoveFile(file);
    _pointclouds.remove(file);

    renderer.removeCloud();
  }


  void doToggleAxes(bool on)
  {
    if (on)
    {
      renderer.addAxes();
    }
    else
    {
      renderer.removeAxes();
    }
  }


  void doMouseMoved()
  {
    statusUI.mousePositionX = renderer.mouseX;
    statusUI.mousePositionY = renderer.mouseY;
  }
}
