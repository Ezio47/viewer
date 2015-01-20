// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

void log(o) {
    window.console.log(o);
}


class Hub {
    RialtoElement rialtoElement;

    Element cesiumContainer;

    Renderer renderer;

    EventRegistry eventRegistry;

    ViewController viewController;
    AnnotationController annotationController;
    MeasurementController measurementController;
    ModeController modeController;
    SelectionController selectionController;

    // the global repo for loaded data
    PointCloudSet renderablePointCloudSet;

    // the server we're currently connected to
    ProxyFileSystem proxy;

    String defaultServer = "http://www.example.com";
    String currentServer;

    bool isPickingEnabled = true;

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

        var rialtoElement = new RialtoElement();

        eventRegistry.OpenServer.subscribe(_handleOpenServer);
        eventRegistry.CloseServer.subscribe0(_handleCloseServer);
        eventRegistry.OpenFile.subscribe(_handleOpenFile);
        eventRegistry.CloseFile.subscribe(_handleCloseFile);

        renderablePointCloudSet = new PointCloudSet();

        cesium.onMouseMove((x,y) => eventRegistry.MouseMove.fire(new MouseData.fromXy(x,y)));
        cesium.onMouseDown((x,y,b) => eventRegistry.MouseDown.fire(new MouseData.fromXyb(x,y,b)));
        cesium.onMouseUp((x,y,b) => eventRegistry.MouseUp.fire(new MouseData.fromXyb(x,y,b)));
        cesium.onMouseWheel((d) => eventRegistry.MouseWheel.fire(new WheelData.fromD(d.toDouble())));
        // onKeyDown...
        // onKeyUp...
        // onResize...

        modeController = new ModeController();
        viewController = new ViewController();
        annotationController = new AnnotationController();
        measurementController = new MeasurementController();
        selectionController = new SelectionController();

        renderablePointCloudSet = new PointCloudSet();

        renderer = new Renderer(renderablePointCloudSet);

        cesium.setUpdateFunction(renderer.checkUpdate);

        eventRegistry.ChangeMode.fire(new ModeData(ModeData.VIEW));
    }

    int get width => window.innerWidth;
    int get height => window.innerHeight;

    void _handleOpenServer(String server) {
        currentServer = null;
        proxy = new ProxyFileSystem(server);
        proxy.load().then((_) => eventRegistry.OpenServerCompleted.fire0());
    }

    void _handleCloseServer() {
        currentServer = null;
        if (proxy != null) {
            proxy.close();
            proxy = null;
        }
        eventRegistry.CloseServerCompleted.fire0();
    }

    void _handleOpenFile(String webpath) {
        FileProxy file = proxy.getFileProxy(webpath);

        file.create().then((PointCloud pointCloud) {
            renderablePointCloudSet.addCloud(pointCloud);

            renderer.updateNeeded = true;
            eventRegistry.OpenFileCompleted.fire(webpath);
        });

    }

    void _handleCloseFile(String webpath) {

        renderablePointCloudSet.removeCloud(webpath);

        renderer.updateNeeded = true;

        eventRegistry.CloseFileCompleted.fire(webpath);
    }
}
