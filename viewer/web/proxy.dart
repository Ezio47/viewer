library proxy;

import 'dart:core';
import 'dart:convert';
import 'comms.dart';
import 'point_cloud_generator.dart';
import 'point_cloud.dart';

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

    Comms get comms => parent.comms;

    String get fullpath {
        if (parent != null) {
            String s = parent.fullpath + name;
            return s;
        }

        return name;
    }

    List<Proxy> _parseDirString(Map<String, Object> map) {
        var list = new List<Proxy>();

        for (var key in map.keys) {
            var value = map[key];

            var values = value as List<String>;

            switch (key) {
                case "dirs":
                    values.forEach((v) => list.add(new DirectoryProxy(v, this)));
                    break;
                case "files":
                    values.forEach((v) => list.add(new FileProxy(v, this)));
                    break;
                default:
                    throw new Error();
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
        sources = _parseDirString(data);
    }

    Comms get comms => _comms;
}


class DirectoryProxy extends Proxy {

    DirectoryProxy(String dirpath, Proxy myparent) : super(dirpath, myparent) {
        assert(name.endsWith("/"));
    }

    @override void load() {
        String json = comms.read(fullpath);
        var data = JSON.decode(json);
        sources = _parseDirString(data);
    }
}


class FileProxy extends Proxy {
    String name;
    List<String> dims;
    int numPoints;

    FileProxy(String filepath, Proxy myparent) : super(filepath, myparent) {
        assert(!name.endsWith("/"));
    }

    @override void load() {
        String json = comms.read(fullpath);
        var data = JSON.decode(json);
        sources = null;

        _parseFileString(data);
    }

    void _parseFileString(Map<String, Object> map) {

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
                default:
                    throw new Error();
            }
        }
    }

    PointCloud create() {
        PointCloud cloud = PointCloudGenerator.generate(name);
        return cloud;
    }
}
