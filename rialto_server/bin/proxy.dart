part of rialto.server;


class ProxyFileSystem {
    Map<String, ProxyItem> _map = new Map<String, ProxyItem>();
    ProxyItem _root;
    String _fspathRoot;

    ProxyFileSystem.build(String fspath) : _fspathRoot = fspath {

        _root = _add(fspath);
        var dir = new Directory(fspath);

        dir.listSync(recursive: true, followLinks: false).forEach((FileSystemEntity entity) {
            if (entity is File) {
                _add(entity.path);
            } else if (entity is Directory) {
                _add(entity.path);
            } else if (entity is Link) {
                // do nothing
            } else {
                throw new Exception("unkown file system entity type");
            }
        });
    }

    bool _isWebPath(String webpath) {
        assert(webpath.startsWith(_fspathRoot) == false);
        return (webpath[0] == "/");
    }

    String _toWebPath(String fspath) {
        String webpath = "/" + path.relative(fspath, from: _fspathRoot);
        if (webpath == "/.") webpath = "/";
        return webpath;
    }

    String toFsPath(String webpath) {
        assert(!_fspathRoot.endsWith("/"));
        assert(webpath.startsWith("/"));

        String fspath = _fspathRoot + webpath;
        print("converted $webpath to $fspath");

        return fspath;
    }


    void setEntry(ProxyItem item) {
        assert(_isWebPath(item.webpath));
        _map[item.webpath] = item;
    }

    void clearEntry(String webpath) {
        assert(_isWebPath(webpath));
        if (_map.containsKey(webpath)) _map.remove(webpath);
    }

    ProxyItem getEntry(String webpath) {
        assert(_isWebPath(webpath));

        if (!_map.containsKey(webpath)) return null;

        return _map[webpath];
    }

    ProxyItem _add(String fspath) {
        final String webpath = _toWebPath(fspath);
        var proxy = getEntry(webpath);
        if (proxy != null) {
            // race condition...
            _update(webpath);
            return proxy;
        }

        if (FileSystemEntity.isFileSync(fspath)) {
            var file = new File(fspath);
            var proxy = new FileProxy(this, file);
            setEntry(proxy);
            return proxy;
        }
        if (FileSystemEntity.isDirectorySync(fspath)) {
            var dir = new Directory(fspath);
            var proxy = new DirectoryProxy(this, dir);
            setEntry(proxy);
            return proxy;
        }
        if (FileSystemEntity.isLinkSync(fspath)) {
            // ignore
            return null;
        }
        throw new Exception("unknown file type");
    }

    void _update(String fspath) {
        final String webpath = _toWebPath(fspath);
        var proxy = getEntry(webpath);

        if (proxy == null) {
            // race condition...
            _add(fspath);
            return;
        }

        proxy.update();
    }

    void _remove(String fspath) {
        final String webpath = _toWebPath(fspath);
        if (getEntry(webpath) == null) {
            // race condition...
            return;
        }

        clearEntry(webpath);
    }

    void handleWatchEvent(WatchEvent e) {
        print("event: $e");
        if (e.type == ChangeType.ADD) {
            _add(e.path);
            return;
        }

        if (e.type == ChangeType.REMOVE) {
            _remove(e.path);
            return;
        }

        if (e.type == ChangeType.MODIFY) {
            _update(e.path);
            return;
        }

        throw new Exception("unknown file event");
    }

    void dump() {
        _root.dump(0);
    }

    void mapdump() {
        _map.forEach((k,v) {
            print("** $k");
            if (v is DirectoryProxy) {
                v.children.forEach((c) => print("     $c"));
            }
        });
    }
}


abstract class ProxyItem {
    FileSystemEntity _entity;
    ProxyFileSystem _proxyFs;
    String _webpath;

    ProxyItem(ProxyFileSystem proxyFs, FileSystemEntity entity)
            : _entity = entity,
              _proxyFs = proxyFs {
        _webpath = proxyFs._toWebPath(entity.path);
    }

    void update();

    void dump(int);

    String get webpath => _webpath;

    String toString() {
        return webpath;
    }
}


class DirectoryProxy extends ProxyItem {
    var children = new List<String>(); // uses webpaths
    Directory _directory;

    DirectoryProxy(ProxyFileSystem proxyFs, Directory directory)
            : super(proxyFs, directory),
              _directory = directory {
        update();
    }

    @override
    void update() {
        children.clear();

        _directory.listSync(recursive: false, followLinks: false).forEach((FileSystemEntity entity) {
            if (entity is File) {
                final String webpath = _proxyFs._toWebPath(entity.path);
                children.add(webpath);
            } else if (entity is Directory) {
                final String webpath = _proxyFs._toWebPath(entity.path);
                children.add(webpath);
            } else if (entity is Link) {
                // do nothing
            } else {
                throw new Exception("unkown file system entity type");

            }
        });
    }

    @override
    void dump(int level) {
        var indent = "   " * level;
        print("D $indent =${webpath}=");
        children.forEach((e) {
            var proxy = _proxyFs.getEntry(e);
            proxy.dump(level + 1);
        });
    }
}


class FileProxy extends ProxyItem {
    File _file;
    int size;

    FileProxy(ProxyFileSystem proxyFs, File file)
            : super(proxyFs, file),
              _file = file {
        update();
    }

    @override
    void update() {
        size = _file.statSync().size;
    }

    @override
    void dump(int level) {
        var indent = "   " * level;
        print("F $indent $webpath  ($size)");
    }

    File get file => _file;
}
