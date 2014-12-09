// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class CommandRegistry {
    Hub _hub;

    CommandRegistry() {
        _hub = Hub.root;
    }

    Future<bool> doOpenServer(String server) {
        _hub.proxy = new ProxyFileSystem(server);
        return _hub.proxy.load();
    }

    void doCloseServer() {
        if (proxy != null)
        {
            _hub.proxy.close();
            _hub.proxy = null;
        }
    }

    void doAddFile(FileProxy file) {
        _hub.layerPanel.doAddFile(file.webpath, file.displayName);

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
    }

    void doRemoveFile(String webpath) {
        _hub.layerPanel.doRemoveFile(webpath);

        _hub.renderablePointCloudSet.removeCloud(webpath);

        _hub.renderer.update();
    }
}
