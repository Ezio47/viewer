library proxy;

import 'dart:core';
import 'dart:convert';
import 'comms.dart';
import 'point_cloud_generator.dart';
import 'point_cloud.dart';
import 'rialto_exceptions.dart';

//import 'package:three/three.dart';
//import 'dart:math' as Math;
//import 'package:vector_math/vector_math.dart';


abstract class Proxy {

    bool isLoaded;
    List<Proxy> sources;
    Proxy parent;
    String name;

    Proxy(String rname, Proxy rparent)
            : isLoaded = false {
        name = rname;
        parent = rparent;

        assert(name != null);
    }

    void load();
    void close() {
        root._close();
        comms.close();
    }

    void _close();

    ServerProxy get root {
        if (parent != null) return parent.root;
        assert(this is ServerProxy);
        return this;
    }

    Comms get comms => parent.comms;

    String get fullpath {
        if (parent != null) {
            String s = parent.fullpath + name;
            return s;
        }

        return name;
    }

    List<Proxy> _parseString(Map<String, Object> map) {
        var list = new List<Proxy>();

        for (var key in map.keys) {
            var value = map[key];

            var values = value as List<Object>;

            switch (key) {
                case "dirs":
                    for (var v in values) {
                        assert(v is Map);
                        Map m = v as Map;
                        list.add(new DirectoryProxy(m["name"], m, this));
                    }
                    break;
                case "files":
                    for (var v in values) {
                        assert(v is Map);
                        Map m = v as Map;
                        list.add(new FileProxy(m["name"], m, this));
                    }
                    break;
                default:
                    throw new RialtoArgumentError("invalid key in proxy data map");
            }
        }

        return list;
    }
}


class ServerProxy extends Proxy {

    Comms _comms;

    ServerProxy(String server) : super(server, null) {
        if (server != "http://www.example.com/") throw new Error();
        assert(server.endsWith("/"));

        _comms = new FauxComms(server);
        _comms.open();
    }

    @override void load() {
        String json = comms.read(fullpath);
        var data = JSON.decode(json);
        sources = _parseString(data);
    }

    Comms get comms => _comms;

    @override void _close() {
        if (sources != null) {
            sources.forEach((p) => p._close());
        }
    }
}


class DirectoryProxy extends Proxy {

    DirectoryProxy(String dirpath, Map map, Proxy myparent) : super(dirpath, myparent) {
        assert(name.endsWith("/"));
        _parseDirectoryMap(map);
    }

    @override void load() {
        String json = comms.read(fullpath);
        var data = JSON.decode(json);
        sources = _parseString(data);
    }

    void _parseDirectoryMap(Map<String, Object> map) {

        for (var key in map.keys) {
            var value = map[key];

            switch (key) {
                case "name":
                    var n = value as String;
                    if (n != name) throw new RialtoArgumentError("DirectoryProxy parser error on 'name'");
                    break;
                default:
                    throw new RialtoArgumentError("invalid key in DirectoryProxy map");
            }
        }
    }

    @override void _close() {
        if (sources != null) {
            sources.forEach((p) => p._close());
        }
    }
}


class FileProxy extends Proxy {
    String name;
    List<String> dims;
    int numPoints = -1;

    FileProxy(String filepath, Map map, Proxy myparent) : super(filepath, myparent) {
        assert(!name.endsWith("/"));
        _parseFileMap(map);
    }

    @override void load() {
        //String json = comms.read(fullpath);
        //var data = JSON.decode(json);
        //sources = null;

        //_parseFileString(data);
    }

    void _parseFileMap(Map<String, Object> map) {

        for (var key in map.keys) {
            var value = map[key];

            switch (key) {
                case "dims":
                    var values = value as List<String>;
                    dims = values;
                    break;
                case "numpoints":
                    var n = value as int;
                    numPoints = n;
                    break;
                case "name":
                    var n = value as String;
                    if (n != name) throw new RialtoArgumentError("FileProxy parser error on 'name'");
                    break;
                default:
                    throw new RialtoArgumentError("invalid key in FileProxy map");
            }
        }
    }

    PointCloud create() {
        PointCloud cloud = PointCloudGenerator.generate(name, fullpath);
        return cloud;
    }

    @override void _close() {
        assert(sources == null);

        // here we should delete the current PointCloud object for this file
    }
}
