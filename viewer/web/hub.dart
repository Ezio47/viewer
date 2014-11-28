library hub;

import 'dart:core';

import 'elements/render_panel.dart';
import 'elements/status_panel.dart';
import 'elements/info_panel.dart';
import 'elements/display_panel.dart';
import 'elements/layer_panel.dart';
import 'elements/rialto_element.dart';
import 'elements/server_browser_element.dart';
import 'renderer.dart';
import 'renderable_point_cloud_set.dart';
import 'event_registry.dart';
import 'command_registry.dart';


class Hub {
    // the big, public, singleton components
    RialtoElement mainWindow;
    InfoPanel infoPanel;
    DisplayPanel displayPanel;
    LayerPanel layerPanel;
    RenderPanel renderPanel;
    StatusPanel statusPanel;
    ServerBrowserElement serverBrowserElement;

    Renderer renderer;
    EventRegistry eventRegistry;
    CommandRegistry commandRegistry;

    // the global repo for loaded data
    RenderablePointCloudSet renderablePointCloudSet;

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
