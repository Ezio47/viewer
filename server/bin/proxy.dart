import 'dart:core';
import 'dart:io';
import 'package:watcher/watcher.dart';
import 'package:path/path.dart' as path;


class ProxyFileSystem {
    Map<String, ProxyItem> items = new Map<String, ProxyItem>();
    ProxyItem root;
    String fsPath;

    ProxyFileSystem.build(String path) : fsPath = path {

        var dir = new Directory(fsPath);
        root = new DirectoryProxy(this, dir);
        root.update();

        dir.listSync(recursive: true, followLinks: false).forEach((FileSystemEntity entity) {
            if (entity is File) {
                var proxy = new FileProxy(this, entity);
                items[entity.path] = proxy;
            } else if (entity is Directory) {
                var proxy = new DirectoryProxy(this, entity);
                items[entity.path] = proxy;
            } else if (entity is Link) {
                // do nothing
            } else {
                throw new Exception("unkown file system entity type");
            }
        });
    }

    void _add(String path) {
        if (items.containsKey([path])) {
            // race condition...
            _update(path);
            return;
        }

        if (FileSystemEntity.isFileSync(path)) {
            var file = new File(path);
            var proxy = new FileProxy(this, file);
            items[proxy.webpath] = proxy;
            return;
        }
        if (FileSystemEntity.isDirectorySync(path)) {
            var dir = new Directory(path);
            var proxy = new DirectoryProxy(this, dir);
            items[proxy.webpath] = proxy;
            return;
        }
        if (FileSystemEntity.isLinkSync(path)) {
            // ignore
            return;
        }
        throw new Exception("unknown file type");
    }

    void _update(String path) {
        if (!items.containsKey([path])) {
            // race condition...
            _add(path);
            return;
        }

        var proxy = items[path];
        proxy.update();
    }

    void _remove(String path) {
        if (!items.containsKey([path])) {
            // race condition...
            return;
        }

        items.remove(path);
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
        root.dump(0);
    }
}


abstract class ProxyItem {
    FileSystemEntity entity;
    ProxyFileSystem proxyFs;
    String _webpath;

    ProxyItem(ProxyFileSystem this.proxyFs, FileSystemEntity this.entity) {
        _webpath = path.relative(entity.path, from: proxyFs.fsPath);
    }

    void update();

    void dump(int);

    String get webpath => _webpath;

    String toString() {
        return webpath;
    }
}


class DirectoryProxy extends ProxyItem {
    var children = new List<String>();
    Directory directory;

    DirectoryProxy(ProxyFileSystem proxyFs, Directory aDirectory)
            : super(proxyFs, aDirectory),
              directory = aDirectory {
        update();
    }

    @override
    void update() {
        children.clear();

        directory.listSync(recursive: false, followLinks: false).forEach((FileSystemEntity entity) {
            if (entity is File) {
                children.add(entity.path);
            } else if (entity is Directory) {
                children.add(entity.path);
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
        print("D $indent $webpath");
        children.forEach((e) {
            var proxy = proxyFs.items[e];
            proxy.dump(level + 1);
        });
    }
}


class FileProxy extends ProxyItem {
    File file;
    int size;

    FileProxy(ProxyFileSystem proxyFs, File aFile)
            : super(proxyFs, aFile),
              file = aFile {
        update();
    }

    @override
    void update() {
        size = file.statSync().size;
    }

    @override
    void dump(int level) {
        var indent = "   " * level;
        print("F $indent $webpath  ($size)");
    }
}
