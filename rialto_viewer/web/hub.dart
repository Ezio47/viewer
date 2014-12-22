// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

library rialto.viewer;

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math';
import 'dart:typed_data';
import 'dart:web_gl';

import 'package:http/browser_client.dart' as BHttp;
import 'package:http/http.dart' as Http;
import 'package:vector_math/vector_math.dart';

import 'elements/colorization_dialog.dart';
import 'elements/render_panel.dart';
import 'elements/server_dialog.dart';
import 'elements/rialto_element.dart';


part 'annotator.dart';
part 'axes_shape.dart';
part 'box_shape.dart';
part 'camera.dart';
part 'camera_interactor.dart';
part 'cloud_shape.dart';
part 'colorizer.dart';
part 'comms.dart';
part 'event_registry.dart';
part 'fragment_shader.dart';
part 'gl_program.dart';
part 'line_shape.dart';
part 'picker.dart';
part 'point_cloud.dart';
part 'point_cloud_generator.dart';
part 'proxy.dart';
part 'renderable_point_cloud.dart';
part 'renderable_point_cloud_set.dart';
part 'renderer.dart';
part 'render_utils.dart';
part 'rialto_exceptions.dart';
part 'shape.dart';
part 'signal.dart';
part 'utils.dart';
part 'vertex_shader.dart';

int c_width = 500;
int c_height = 500;

class Hub {
    RenderPanel mainRenderPanel;
    RenderPanel navRenderPanel;
    ServerDialog serverDialog;
    ColorizationDialog colorizationDialog;
    RialtoElement rialtoElement;

    Renderer mainRenderer;
    Renderer navRenderer;

    EventRegistry eventRegistry;

    Annotator annotator;

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
        annotator = new Annotator();
    }

    static Hub get root {
        assert(_root != null);
        return _root;
    }

    void init() {
        eventRegistry.OpenServer.subscribe(_handleOpenServer);
        eventRegistry.CloseServer.subscribe0(_handleCloseServer);
        eventRegistry.OpenFile.subscribe(_handleOpenFile);
        eventRegistry.CloseFile.subscribe(_handleCloseFile);

        CanvasElement canvas = querySelector("#mycanvas");

        RenderingContext gl = canvas.getContext3d();
        if (gl == null) {
            return;
        }

        renderablePointCloudSet = new RenderablePointCloudSet();

        mainRenderer = new Renderer(canvas, gl);

        /***
        var domElement = mainRenderer.canvas;
        domElement.onMouseMove.listen(
                (e) => eventRegistry.MouseMove.fire(new MouseMoveData(e.client.x, e.client.y, e.target)));
        domElement.onMouseDown.listen((e) => eventRegistry.MouseDown.fire0());
        domElement.onMouseUp.listen((e) => eventRegistry.MouseUp.fire0());
        window.onResize.listen((e) => eventRegistry.WindowResize.fire0());
        ***/

        mainRenderer.tick(0);
    }

    void _createRenderer() {
        /***
        assert(mainRenderer == null);
        assert(navRenderer == null);

        renderablePointCloudSet = new RenderablePointCloudSet();

        {
            mainRenderer = new Renderer(mainRenderPanel, renderablePointCloudSet, "main");
            mainRenderer.update();
            mainRenderer.animate(0);

            var domElement = mainRenderer.canvas;
            //domElement.text = "main";

            domElement.onMouseMove.listen(
                    (e) => eventRegistry.MouseMove.fire(new MouseMoveData(e.client.x, e.client.y, e.target)));
            domElement.onMouseDown.listen((e) => eventRegistry.MouseDown.fire0());
            domElement.onMouseUp.listen((e) => eventRegistry.MouseUp.fire0());
            window.onResize.listen((e) => eventRegistry.WindowResize.fire0());
        }***/
        /*{
            navRenderer = new Renderer(navRenderPanel, renderablePointCloudSet, "nav");
            navRenderer.update();
            navRenderer.animate(0);

            var domElement = navRenderer.canvas;
            //domElement.text = "nav";

            domElement.onMouseMove.listen(
                    (e) => eventRegistry.MouseMove.fire(new MouseMoveData(e.client.x, e.client.y, e.target)));
            domElement.onMouseDown.listen((e) => eventRegistry.MouseDown.fire());
            domElement.onMouseUp.listen((e) => eventRegistry.MouseUp.fire());
            window.onResize.listen((e) => eventRegistry.WindowResize.fire());
        }*/
    }

    void _handleOpenServer(String server) {
        proxy = new ProxyFileSystem(server);
        proxy.load().then((_) => eventRegistry.OpenServerCompleted.fire0());
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

            mainRenderer.update();
            if (navRenderer != null) {
                navRenderer.update();
            }
        });

        eventRegistry.OpenFileCompleted.fire(webpath);
    }

    void _handleCloseFile(String webpath) {

        renderablePointCloudSet.removeCloud(webpath);

        mainRenderer.update();
        if (navRenderer != null) {
            navRenderer.update();
        }

        eventRegistry.CloseFileCompleted.fire(webpath);
    }
}
