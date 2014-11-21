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

    static Hub _root;
    static Hub get root {
        if (_root == null) _root = new Hub();
        return _root;
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

        settingsUI.minx = renderSource.min.x;
        settingsUI.maxx = renderSource.max.x;
        settingsUI.miny = renderSource.min.y;
        settingsUI.maxy = renderSource.max.y;
        settingsUI.minz = renderSource.min.z;
        settingsUI.maxz = renderSource.max.z;
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

    void bootup() {
        Proxy proxy = new ServerProxy("http://www.example.com/");
        proxy.load();
        List<Proxy> list = proxy.sources;
        proxy = list.firstWhere((e) => e.name == "terrain1.dat");
        //proxy = list.firstWhere((e) => e.name == "oldcube.dat");
        assert(proxy != null);
        doAddFile(proxy);
    }
}
