// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

void log(o) {
    window.console.log(o);
}


class Hub {
    LayerManager layerManager;

    RialtoElement rialtoElement;

    Element cesiumContainer;

    Renderer renderer;

    EventRegistry eventRegistry;

    ViewController viewController;
    AnnotationController annotationController;
    MeasurementController measurementController;
    ModeController modeController;
    SelectionController selectionController;

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
        layerManager = new LayerManager();

        cesium = new CesiumBridge('cesiumContainer');

        var rialtoElement = new RialtoElement();

        eventRegistry.LoadScript.subscribe(_handleLoadScript);

        eventRegistry.OpenFile.subscribe(_handleOpenFile);
        eventRegistry.CloseFile.subscribe(_handleCloseFile);

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

        renderer = new Renderer();

        cesium.setUpdateFunction(renderer.checkUpdate);

        eventRegistry.ChangeMode.fire(new ModeData(ModeData.VIEW));
    }

    int get width => window.innerWidth;
    int get height => window.innerHeight;

    void _handleLoadScript(String url) {
        var s = new InitScript(url);
    }

    void _handleOpenFile(String webpath) {
        Layer layer = layerManager.layers[webpath];
        assert(layer != null);

        PointCloudLayer pcl = layer as PointCloudLayer;
        pcl.load();

        renderer.updateNeeded = true;

        eventRegistry.OpenFileCompleted.fire(webpath);
    }

    void _handleCloseFile(String webpath) {
        renderer.updateNeeded = true;

        eventRegistry.CloseFileCompleted.fire(webpath);
    }
}
