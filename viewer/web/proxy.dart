library proxy;

import 'dart:core';
import 'dart:convert';
import 'dart:async';
import 'comms.dart';
import 'point_cloud_generator.dart';
import 'point_cloud.dart';
import 'rialto_exceptions.dart';


class ProxyFileSystem {
    Map<String, ProxyItem> _map = new Map<String, ProxyItem>(); // webpath -> proxy
    DirectoryProxy root;
    Comms _comms;

    ProxyFileSystem(String server) {

        if (!server.endsWith("/")) server += "/";
        assert(server.endsWith("/"));

        if (server == "http://www.example.com/") {
            _comms = new FauxComms(server);
        } else if (server == "http://localhost:12345/") {
            _comms = new HttpComms(server);
        } else {
            throw new Error();
        }

        _comms.open();

        Map map = new Map(); // BUG - need to load this
        root = new DirectoryProxy(this, "/", null);
    }

    Comms get comms => _comms;

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
    String path;
    String name;

    ProxyItem(ProxyFileSystem this.fileSystem, String this.path, DirectoryProxy this.parent) {
        name = "<${path}>"; // BUG
    }

    void _load();

    void close();

    void dump(int);
}


/*        loaded = false;
        var c = (comms as HttpComms).read2(fullpath).then((s) {
            //var data = JSON.decode(s);
            //print(s);
            PointCloud cloud = PointCloudGenerator.fromString(s);
            return cloud;
        });
        return c;*/



class DirectoryProxy extends ProxyItem {
    List<DirectoryProxy> dirs = new List<DirectoryProxy>();
    List<FileProxy> files = new List<FileProxy>();

    DirectoryProxy(ProxyFileSystem fs, String path, DirectoryProxy parent) : super(fs, path, parent) {
        assert(path.startsWith("/"));

        _load();
    }

    void _loadSubdirs() {
        List<String> subdirs = map["dirs"];
        if (subdirs == null) return;

        subdirs.forEach((subdir) {
            var proxy = new DirectoryProxy(fileSystem, subdir, this);
            proxy._load();
            dirs.add(proxy);
        });
    }

    void _loadFiles() {
        List<String> paths = map["files"];
        if (paths == null) return;

        paths.forEach((path) {
            var proxy = new FileProxy(fileSystem, path, this);
            proxy._load();
            files.add(proxy);
        });
    }

    @override
    void _load() {
        var fjson = fileSystem.comms.readAsString(path);
        var fmap = fjson.then((s) => JSON.decode(s));
        fmap.then((m) {
            map = m;
            _loadSubdirs();
            _loadFiles();
        });
    }

    @override
    void close() {}


    @override
    void dump(int level) {
        var indent = "   " * level;
        print("D $indent =${path}=");
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
    void _load() {
        var fjson = fileSystem.comms.readAsString(path);
        var fmap = fjson.then((s) => JSON.decode(s));
        fmap.then((m) {
            map = m;
        });
    }

    @override void close() {
        // BUG: here we should delete the current PointCloud object for this file
    }


    @override
    void dump(int level) {
        var indent = "   " * level;
        print("F $indent $path  (${map["size"]})");
    }


    PointCloud create() {
        PointCloud cloud = PointCloudGenerator.generate(path, name);
        return cloud;
    }
}
