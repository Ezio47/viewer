library hub;


import 'dart:core';
import 'dart:html';
import 'elements/render_element.dart';
import 'elements/settings_element.dart';
import 'elements/status_element.dart';
import 'renderer.dart';
import 'render_source.dart';
import 'point_cloud.dart';
import 'proxy.dart';


// thje global singleton
Hub hub = new Hub();

class Hub {
    // the big, public, singleton components
    RenderElement renderUI;
    SettingsElement settingsUI;
    StatusElement statusUI;
    Element canvas;
    Renderer renderer;

    // private - the gloabl repo for loaded data
    Map<String, PointCloud> _pointClouds = new Map<String, PointCloud>();


    Hub() {
        return;
    }

    void addLoadedPointCloud(PointCloud cloud)
    {
        _pointClouds[cloud.name] = cloud;
    }

    void doColorize() {
        renderer.unsetSource();

        var renderSource = new RenderSource();
        renderSource.addClouds(_pointClouds.values.toList());

        renderSource.colorize();

        renderer.setSource(renderSource);
    }


    void makeRenderer() {
        // we don't make the renderer until we have to
        if (renderer == null) {
            renderer = new Renderer(canvas);
            renderer.init();
            renderer.animate(0);
        }
    }

    void doAddFile(FileProxy file) {
        settingsUI.doAddFile(file.name, file.fullpath);

        _pointClouds[file.fullpath] = file.create();

        renderer.unsetSource();

        var renderSource = new RenderSource();
        renderSource.addClouds(_pointClouds.values.toList());
        renderer.setSource(renderSource);

        settingsUI.minx = renderSource.low.x;
        settingsUI.maxx = renderSource.high.x;
        settingsUI.miny = renderSource.low.y;
        settingsUI.maxy = renderSource.high.y;
        settingsUI.minz = renderSource.low.z;
        settingsUI.maxz = renderSource.high.z;
        settingsUI.numPoints = renderSource.numPoints;
    }


    void doRemoveFile(String fullpath) {
        settingsUI.doRemoveFile(fullpath);

        renderer.unsetSource();

        var cloud = _pointClouds[fullpath];
        assert(cloud != null);
        _pointClouds.remove(fullpath);

        if (_pointClouds.length > 0) {
            var renderSource = new RenderSource();
            renderSource.addClouds(_pointClouds.values.toList());
            renderer.setSource(renderSource);
        }
    }


    void doToggleAxes(bool on) => renderer.toggleAxesDisplay(on);

    void doToggleBbox(bool on) => renderer.toggleBboxDisplay(on);

    void goHome() => renderer.goHome();

    void doMouseMoved() {
        statusUI.mousePositionX = renderer.mouseX;
        statusUI.mousePositionY = renderer.mouseY;
    }
}
