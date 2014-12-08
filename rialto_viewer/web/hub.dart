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

import 'elements/display_panel.dart';
import 'elements/info_panel.dart';
import 'elements/layer_panel.dart';
import 'elements/render_panel.dart';
import 'elements/rialto_element.dart';
import 'elements/server_browser_element.dart';
import 'elements/status_panel.dart';


part 'axes_object.dart';
part 'bbox_object.dart';
part 'command_registry.dart';
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
part 'utils.dart';


class Hub {
    // the big, public, singleton components
    RialtoElement mainWindow;
    InfoPanel infoPanel;
    DisplayPanel displayPanel;
    LayerPanel layerPanel;
    RenderPanel renderPanel;
    StatusPanel statusPanel;
    ServerBrowserElement serverBrowserElement;
    DialogElement serverDialog;

    Renderer renderer;
    EventRegistry eventRegistry;
    CommandRegistry commandRegistry;

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
        commandRegistry = new CommandRegistry();
    }

    static Hub get root {
        assert(_root != null);
        return _root;
    }

    void init() {
        _createRenderer();
    }

    void _createRenderer() {
        assert(renderer == null);

        renderablePointCloudSet = new RenderablePointCloudSet();

        renderer = new Renderer(renderablePointCloudSet);
        renderer.update();
        renderer.animate(0);

        eventRegistry.start(renderer.canvas);
    }
}
