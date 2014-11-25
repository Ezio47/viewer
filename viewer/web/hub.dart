library hub;


import 'dart:core';
import 'dart:html';
import 'elements/render_element.dart';
import 'elements/settings_element.dart';
import 'elements/status_element.dart';
import 'renderer.dart';
import 'renderable_point_cloud_set.dart';
import 'point_cloud.dart';
import 'proxy.dart';


class Hub {
    // the big, public, singleton components
    RenderElement renderUI;
    SettingsElement settingsUI;
    StatusElement statusUI;
    Element canvas;
    Renderer renderer;

    // private - the global repo for loaded data
    RenderablePointCloudSet renderablePointCloudSet;


    Hub() {
        return;
    }

    static Hub _root;
    static Hub get root {
        if (_root == null) _root = new Hub();
        return _root;
    }

    void doColorize() {
        renderablePointCloudSet.colorize();
        renderer.update();
    }


    void makeRenderer() {
        assert(renderer == null);

        renderablePointCloudSet = new RenderablePointCloudSet();

        renderer = new Renderer(canvas);
        renderer.init(renderablePointCloudSet);
        renderer.update();
        renderer.animate(0);
    }

    void doAddFile(FileProxy file) {
        settingsUI.doAddFile(file.name, file.fullpath);

        PointCloud pointCloud = file.create();

        renderablePointCloudSet.addCloud(pointCloud);

        renderer.update();

        settingsUI.minx = renderablePointCloudSet.min.x;
        settingsUI.maxx = renderablePointCloudSet.max.x;
        settingsUI.miny = renderablePointCloudSet.min.y;
        settingsUI.maxy = renderablePointCloudSet.max.y;
        settingsUI.minz = renderablePointCloudSet.min.z;
        settingsUI.maxz = renderablePointCloudSet.max.z;
        settingsUI.numPoints = renderablePointCloudSet.numPoints;
    }


    void doRemoveFile(String fullpath) {
        settingsUI.doRemoveFile(fullpath);

        renderablePointCloudSet.removeCloud(fullpath);

        renderer.update();
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
        proxy = list.firstWhere((e) => e.name == "terrain2.dat");
        doAddFile(proxy);
        renderer.toggleBboxDisplay(true);
    }
}
