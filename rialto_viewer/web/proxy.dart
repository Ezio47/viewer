// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class ProxyFileSystem {
    Map<String, ProxyItem> _map = new Map<String, ProxyItem>(); // webpath -> proxy
    DirectoryProxy root;
    Comms _comms;
    String _server;

    ProxyFileSystem(String server) {
        _server = server;

        if (!_server.endsWith("/")) _server += "/";
        assert(_server.endsWith("/"));
    }

    Future<bool> load() {
        if (_server == "http://www.example.com/") {
            _comms = new FauxComms(_server);
        } else if (_server == "http://localhost:12345/") {
            _comms = new HttpComms(_server);
        } else {
            throw new Error();
        }

        _comms.open();

        root = new DirectoryProxy(this, "/", null);
        var f = root._load();
        return f;
    }

    Comms get comms => _comms;

    FileProxy getFileProxy(String webpath) {
        var p = _map[webpath];
        if (p == null || p is! FileProxy) return null;
        return p;
    }

    void _addToMap(ProxyItem proxy) {
        String key = proxy.webpath;
        assert(!_map.containsKey(key));
        assert(!_map.containsValue(proxy));
        _map[key] = proxy;
    }

    void close() {
        _map.forEach((k, v) {
            v.close();
        });

        comms.close();
    }

    void dump() {
        root.dump(0);
    }
}


abstract class ProxyItem {
    ProxyFileSystem fileSystem;
    DirectoryProxy parent;
    Map map = new Map();
    String webpath;

    ProxyItem(ProxyFileSystem this.fileSystem, String this.webpath, DirectoryProxy this.parent);

    String get displayName {
        int p = webpath.lastIndexOf("/");
        int q = webpath.length;
        assert(q - p > 0);
        String s = webpath.substring(p + 1, q);
        return s;
    }

    Future<bool> _load();

    void close();

    void dump(int);
}


class DirectoryProxy extends ProxyItem {
    List<DirectoryProxy> dirs = new List<DirectoryProxy>();
    List<FileProxy> files = new List<FileProxy>();

    DirectoryProxy(ProxyFileSystem fs, String path, DirectoryProxy parent) : super(fs, path, parent) {
        assert(path.startsWith("/"));
    }

    Future<bool> _loadSubdirs() {
        var c = new Completer();

        List<String> subdirs = map["dirs"];
        if (subdirs == null) {
            c.complete(true);
            return c.future;
        }

        List<Future<bool>> fs = new List<Future<bool>>();
        subdirs.forEach((subdir) {
            var proxy = new DirectoryProxy(fileSystem, subdir, this);
            var f = proxy._load().then((_) {
                dirs.add(proxy);
                fileSystem._addToMap(proxy);
            });
            fs.add(f);
        });
        Future.wait(fs).then((_) {
            c.complete(true);
        });
        return c.future;
    }

    Future<bool> _loadFiles() {
        var c = new Completer();


        List<String> paths = map["files"];
        if (paths == null) {
            c.complete(true);
            return c.future;
        }

        List<Future<bool>> fs = new List<Future<bool>>();
        paths.forEach((path) {
            var proxy = new FileProxy(fileSystem, path, this);
            var f = proxy._load().then((_) {
                files.add(proxy);
                fileSystem._addToMap(proxy);
            });
            fs.add(f);
        });
        Future.wait(fs).then((_) {
            c.complete(true);
        });
        return c.future;
    }

    @override
    Future<bool> _load() {
        var c = new Completer();

        var f = fileSystem.comms.readAsString(webpath).then((json) {
            map = JSON.decode(json);
            return _loadSubdirs().then((_) {
                return _loadFiles();
            });
        });

        return f;
    }

    @override
    void close() {}


    @override
    void dump(int level) {
        var indent = "   " * level;
        print("D $indent =${webpath}=");
        dirs.forEach((child) {
            child.dump(level + 1);
        });
        files.forEach((child) {
            child.dump(level + 1);
        });
    }
}


class FileProxy extends ProxyItem {

    FileProxy(ProxyFileSystem fs, String path, DirectoryProxy parent) : super(fs, path, parent) {
        assert(!path.endsWith("/"));
    }

    @override
    Future<bool> _load() {
        var c = new Completer();

        var f = fileSystem.comms.readAsString(webpath).then((json) {
            map = JSON.decode(json);
        });
        c.complete(f);
        return c.future;
    }

    @override void close() {
        // BUG: here we should delete the current PointCloud object for this file
    }


    @override
    void dump(int level) {
        var indent = "   " * level;
        print("F $indent $webpath  (${map["size"]})");
    }


    Future<PointCloud> create() {
        if (fileSystem.comms is FauxComms) {
            PointCloud cloud = PointCloudGenerator.generate(webpath, displayName);
            return Utils.toFuture(cloud);
        }

        PointCloud cloud = PointCloudGenerator.fromRawInit(webpath, displayName);

        var handler = (ByteBuffer buf, int used) {
            int numBytes = used;
            int numFloats = numBytes ~/ 4;
            int numPoints = numFloats ~/ 3;
            assert(numPoints * 3 * 4 == numBytes);

            Float32List xlist = new Float32List(numPoints);
            Float32List ylist = new Float32List(numPoints);
            Float32List zlist = new Float32List(numPoints);

            Float32List tmp = new Float32List.view(buf);
            for (int i = 0; i < numPoints; i++) {
                xlist[i] = tmp[i * 3 + 0];
                ylist[i] = tmp[i * 3 + 1];
                zlist[i] = tmp[i * 3 + 2];
            }

            PointCloudGenerator.fromRawAdd(cloud, "positions.x", xlist);
            PointCloudGenerator.fromRawAdd(cloud, "positions.y", ylist);
            PointCloudGenerator.fromRawAdd(cloud, "positions.z", zlist);
        };

        var f = fileSystem.comms.readAsBytes(webpath, handler).then((bool v) {
            return Utils.toFuture(cloud);
        });
        return f;
    }
}
