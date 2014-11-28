library hub;


import 'dart:core';
import 'dart:html';
import 'elements/render_panel.dart';
import 'elements/status_panel.dart';
import 'elements/info_panel.dart';
import 'elements/display_panel.dart';
import 'elements/layer_panel.dart';
import 'elements/rialto_element.dart';
import 'elements/server_browser_element.dart';
import 'renderer.dart';
import 'renderable_point_cloud_set.dart';
import 'point_cloud.dart';
import 'proxy.dart';


class Hub {
    // the big, public, singleton components
    RialtoElement mainWindow;
    InfoPanel infoPanel;
    DisplayPanel displayPanel;
    LayerPanel layerPanel;
    RenderPanel renderPanel;
    Element canvas;
    StatusPanel statusPanel;
    ServerBrowserElement serverBrowserElement;

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
        layerPanel.doAddFile(file.name, file.fullpath);

        PointCloud pointCloud = file.create();

        renderablePointCloudSet.addCloud(pointCloud);

        renderer.update();

        infoPanel.minx = renderablePointCloudSet.min.x;
        infoPanel.maxx = renderablePointCloudSet.max.x;
        infoPanel.miny = renderablePointCloudSet.min.y;
        infoPanel.maxy = renderablePointCloudSet.max.y;
        infoPanel.minz = renderablePointCloudSet.min.z;
        infoPanel.maxz = renderablePointCloudSet.max.z;
        infoPanel.numPoints = renderablePointCloudSet.numPoints;
    }


    void doRemoveFile(String fullpath) {
        layerPanel.doRemoveFile(fullpath);

        renderablePointCloudSet.removeCloud(fullpath);

        renderer.update();
    }


    void doToggleAxes(bool on) => renderer.toggleAxesDisplay(on);

    void doToggleBbox(bool on) => renderer.toggleBboxDisplay(on);

    void goHome() => renderer.goHome();

    void doMouseMoved() {
        statusPanel.mousePositionX = renderer.mouseX;
        statusPanel.mousePositionY = renderer.mouseY;
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
