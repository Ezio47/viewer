// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

library rialto.viewer;

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math';
import 'dart:typed_data';
import 'dart:js';

import 'package:http/browser_client.dart' as BHttp;
import 'package:http/http.dart' as Http;
import 'package:vector_math/vector_math.dart';

import 'elements/colorization_dialog.dart';
import 'elements/render_panel.dart';
import 'elements/server_dialog.dart';
import 'elements/rialto_element.dart';

part 'annotation_controller.dart';
part 'cesium/cesium_bridge.dart';
part 'colorizer.dart';
part 'comms.dart';
part 'event_registry.dart';
part 'measurement_controller.dart';
part 'mode_controller.dart';
part 'point_cloud.dart';
part 'point_cloud_generator.dart';
part 'proxy.dart';
part 'renderable_point_cloud.dart';
part 'renderable_point_cloud_set.dart';
part 'renderer.dart';
part 'selection_conroller.dart';

part 'utils/color.dart';
part 'utils/rialto_exceptions.dart';
part 'utils/signal.dart';
part 'utils/utils.dart';

part 'webgl/annotation_shape.dart';
part 'webgl/axes_shape.dart';
part 'webgl/bbox_shape.dart';
part 'webgl/cloud_shape.dart';
part 'webgl/measurement_shape.dart';
part 'webgl/picker.dart';
part 'webgl/shape.dart';


void log(o) {
    window.console.log(o);
}


class Hub {
    RenderPanel renderPanel;
    ServerDialog serverDialog;
    ColorizationDialog colorizationDialog;
    RialtoElement rialtoElement;

    Element cesiumContainer;

    Renderer renderer;

    EventRegistry eventRegistry;

    AnnotationController annotationController;
    Picker picker;
    MeasurementController measurementController;
    ModeController modeController;
    SelectionController selectionController;

    // the global repo for loaded data
    RenderablePointCloudSet renderablePointCloudSet;

    // the server we're currently connected to
    ProxyFileSystem proxy;

    String defaultServer = "http://www.example.com";
    String currentServer;

    bool isPickingEnabled = true;

    Map<int, Shape> shapesMap = {};
    List<Shape> shapesList = [];

    // singleton
    static Hub _root;

    CesiumBridge cesium;

    Hub() {
        _root = this;
        eventRegistry = new EventRegistry();
    }

    static Hub get root {
        assert(_root != null);
        return _root;
    }

    void init() {
        cesium = new CesiumBridge('cesiumContainer');

        eventRegistry.OpenServer.subscribe(_handleOpenServer);
        eventRegistry.CloseServer.subscribe0(_handleCloseServer);
        eventRegistry.OpenFile.subscribe(_handleOpenFile);
        eventRegistry.CloseFile.subscribe(_handleCloseFile);

        renderablePointCloudSet = new RenderablePointCloudSet();

        renderer = new Renderer(renderablePointCloudSet);

        cesium.setUpdateFunction(renderer.checkUpdate);

        var domElement = cesiumContainer;
        window.onMouseMove.listen((e) => eventRegistry.MouseMove.fire(new MouseData(e)));
        window.onMouseDown.listen((e) => eventRegistry.MouseDown.fire(new MouseData(e)));
        window.onMouseUp.listen((e) => eventRegistry.MouseUp.fire(new MouseData(e)));
        window.onMouseWheel.listen((e) => eventRegistry.MouseWheel.fire(new WheelData(e)));
        window.onKeyUp.listen((e) => eventRegistry.KeyUp.fire(new KeyboardData(e)));
        window.onKeyDown.listen((e) => eventRegistry.KeyDown.fire(new KeyboardData(e)));
        window.onResize.listen((e) => eventRegistry.WindowResize.fire0());

        modeController = new ModeController();
        annotationController = new AnnotationController();
        measurementController = new MeasurementController();
        selectionController = new SelectionController();

        renderablePointCloudSet = new RenderablePointCloudSet();

        renderer = new Renderer(renderablePointCloudSet);

        picker = new Picker();

        eventRegistry.ChangeMode.fire(new ModeData(ModeData.MOVEMENT));
    }

    int get width => window.innerWidth;
    int get height => window.innerHeight;

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

            renderer.update();
        });

        eventRegistry.OpenFileCompleted.fire(webpath);
    }

    void _handleCloseFile(String webpath) {

        renderablePointCloudSet.removeCloud(webpath);

        renderer.update();

        eventRegistry.CloseFileCompleted.fire(webpath);
    }
}
