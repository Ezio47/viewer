// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class CommandRegistry {
    Hub _hub;

    CommandRegistry() {
        _hub = Hub.root;
    }

    void start() {
        _hub.eventRegistry.OpenServer.subscribe(_handleOpenServer);
        _hub.eventRegistry.CloseServer.subscribe(_handleCloseServer);
        _hub.eventRegistry.OpenFile.subscribe(_handleOpenFile);
        _hub.eventRegistry.CloseFile.subscribe(_handleCloseFile);
    }

    void _handleOpenServer(String server) {
        _hub.proxy = new ProxyFileSystem(server);
        _hub.proxy.load().then((_) => _hub.eventRegistry.OpenServerCompleted.fire());
    }

    void _handleCloseServer() {
        if (_hub.proxy != null)
        {
            _hub.proxy.close();
            _hub.proxy = null;
        }
    }

    void _handleOpenFile(String webpath) {
        FileProxy file = _hub.proxy.getFileProxy(webpath);

        file.create().then((PointCloud pointCloud) {
            _hub.renderablePointCloudSet.addCloud(pointCloud);

            _hub.renderer.update();

            _hub.infoPanel.minx = _hub.renderablePointCloudSet.min.x;
            _hub.infoPanel.maxx = _hub.renderablePointCloudSet.max.x;
            _hub.infoPanel.miny = _hub.renderablePointCloudSet.min.y;
            _hub.infoPanel.maxy = _hub.renderablePointCloudSet.max.y;
            _hub.infoPanel.minz = _hub.renderablePointCloudSet.min.z;
            _hub.infoPanel.maxz = _hub.renderablePointCloudSet.max.z;
            _hub.infoPanel.numPoints = _hub.renderablePointCloudSet.numPoints;
        });

        _hub.layerPanel.doAddFile(file.webpath, file.displayName);
    }

    void _handleCloseFile(String webpath) {
        _hub.layerPanel.doRemoveFile(webpath);

        _hub.renderablePointCloudSet.removeCloud(webpath);

        _hub.renderer.update();
    }
}
