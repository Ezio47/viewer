// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

library rialto.viewer;

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math' as Math;
import 'dart:typed_data';

import 'package:http/browser_client.dart' as BHttp;
import 'package:http/http.dart' as Http;
import 'package:three/extras/controls/trackball_controls.dart';
import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart' hide Ray;

import 'elements/colorization_dialog.dart';
import 'elements/display_panel.dart';
import 'elements/info_panel.dart';
import 'elements/layer_panel.dart';
import 'elements/render_panel.dart';
import 'elements/rialto_element.dart';
import 'elements/server_browser_element.dart';
import 'elements/status_panel.dart';


part 'axes_object.dart';
part 'bbox_object.dart';
part 'colorizer.dart';
part 'comms.dart';
part 'event_registry.dart';
part 'point_cloud.dart';
part 'point_cloud_generator.dart';
part 'proxy.dart';
part 'renderable_point_cloud.dart';
part 'renderable_point_cloud_set.dart';
part 'renderer.dart';
part 'render_utils.dart';
part 'rialto_exceptions.dart';
part 'signal.dart';
part 'utils.dart';


class Hub {
    // the big, public, singleton components
    RialtoElement mainWindow;
    InfoPanel infoPanel;
    DisplayPanel displayPanel;
    LayerPanel layerPanel;
    RenderPanel renderPanel;
    StatusPanel statusPanel;
    DialogElement serverDialogElement;
    ServerBrowserElement serverDialog;
    DialogElement colorizationDialogElement;
    ColorizationDialog colorizationDialog;

    Renderer renderer;
    EventRegistry eventRegistry;

    // the global repo for loaded data
    RenderablePointCloudSet renderablePointCloudSet;

    // the server we're currently connected to
    ProxyFileSystem proxy;

    String defaultServer = "http://www.example.com";
    String currentServer;

    // singleton
    static Hub _root;


    Hub() {
        _root = this;
        eventRegistry = new EventRegistry();
    }

    static Hub get root {
        assert(_root != null);
        return _root;
    }

    void init() {
        eventRegistry.OpenServer.subscribe(_handleOpenServer);
        eventRegistry.CloseServer.subscribe(_handleCloseServer);
        eventRegistry.OpenFile.subscribe(_handleOpenFile);
        eventRegistry.CloseFile.subscribe(_handleCloseFile);

        _createRenderer();
    }

    void _createRenderer() {
        assert(renderer == null);

        renderablePointCloudSet = new RenderablePointCloudSet();

        renderer = new Renderer(renderablePointCloudSet);
        renderer.update();
        renderer.animate(0);

        var domElement = renderer.canvas;

        domElement.onMouseMove.listen((e) => eventRegistry.MouseMove.fire(new MouseMoveData(e.client.x, e.client.y)));
        domElement.onMouseDown.listen((e) => eventRegistry.MouseDown.fire());
        domElement.onMouseUp.listen((e) => eventRegistry.MouseUp.fire());
        window.onResize.listen((e) => eventRegistry.WindowResize.fire());
    }

    void _handleOpenServer(String server) {
        proxy = new ProxyFileSystem(server);
        proxy.load().then((_) => eventRegistry.OpenServerCompleted.fire());
    }

    void _handleCloseServer() {
        if (proxy != null) {
            proxy.close();
            proxy = null;
        }
    }

    void _handleOpenFile(String webpath) {
        FileProxy file = proxy.getFileProxy(webpath);

        file.create().then((PointCloud pointCloud) {
            renderablePointCloudSet.addCloud(pointCloud);

            renderer.update();

            infoPanel.minx = renderablePointCloudSet.min.x;
            infoPanel.maxx = renderablePointCloudSet.max.x;
            infoPanel.miny = renderablePointCloudSet.min.y;
            infoPanel.maxy = renderablePointCloudSet.max.y;
            infoPanel.minz = renderablePointCloudSet.min.z;
            infoPanel.maxz = renderablePointCloudSet.max.z;
            infoPanel.numPoints = renderablePointCloudSet.numPoints;
        });

        layerPanel.doAddFile(file.webpath, file.displayName);
    }

    void _handleCloseFile(String webpath) {
        layerPanel.doRemoveFile(webpath);

        renderablePointCloudSet.removeCloud(webpath);

        renderer.update();
    }
}
