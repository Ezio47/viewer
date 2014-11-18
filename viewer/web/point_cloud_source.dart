library point_cloud_source;

import 'dart:core';
import 'dart:convert';
import 'comms.dart';
import 'cloud_generator.dart';

//import 'package:three/three.dart';
//import 'dart:math' as Math;
//import 'package:vector_math/vector_math.dart';


abstract class PointCloudSource {

    bool isLoaded;
    List<PointCloudSource> sources;
    PointCloudSource parent;
    String path;

    PointCloudSource(String rpath, PointCloudSource rparent)
            : isLoaded = false {
        path = rpath;
        parent = rparent;

        assert(path != null);
    }

    void load();

    Comms get comms => parent.comms;

    String getFullPath() {
        if (parent != null) {
            String s = parent.getFullPath() + path;
            return s;
        }

        return path;
    }

    List<PointCloudSource> _parseDirString(Map<String, Object> map) {
        var list = new List<PointCloudSource>();

        for (var key in map.keys) {
            var value = map[key];

            var values = value as List<String>;

            switch (key) {
                case "dirs":
                    values.forEach((v) => list.add(new PointCloudDirectory(v, this)));
                    break;
                case "files":
                    values.forEach((v) => list.add(new PointCloudFile(v, this)));
                    break;
                default:
                    throw new Error();
            }
        }

        return list;
    }
}


class PointCloudServer extends PointCloudSource {

    Comms _comms;

    PointCloudServer(String server) : super(server, null) {
        if (server != "http://www.example.com/") throw new Error();
        assert(server.endsWith("/"));

        _comms = new FauxComms(server);
        _comms.open();
    }

    @override void load() {
        String json = comms.read(getFullPath());
        var data = JSON.decode(json);
        sources = _parseDirString(data);
    }

    Comms get comms => _comms;
}


class PointCloudDirectory extends PointCloudSource {

    PointCloudDirectory(String dirpath, PointCloudSource myparent) : super(dirpath, myparent) {
        assert(path.endsWith("/"));
    }

    @override void load() {
        String json = comms.read(getFullPath());
        var data = JSON.decode(json);
        sources = _parseDirString(data);
    }
}


class PointCloudFile extends PointCloudSource {
    String path;
    List<String> dims;
    int numPoints;

    PointCloudFile(String filepath, PointCloudSource myparent) : super(filepath, myparent) {
        assert(!path.endsWith("/"));
    }

    @override void load() {
        String json = comms.read(getFullPath());
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

    Object readData() {
        switch (path) {
            case "file1":
                return CloudGenerator.makeTerrain();
            case "file2":
                return CloudGenerator.makeNewCube();
            case "file3":
                return CloudGenerator.makeRandom();
            case "file4":
                return CloudGenerator.makeLine();
            default:
                throw new Error();
        }
    }
}
