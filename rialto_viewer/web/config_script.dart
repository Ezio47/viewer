// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class ConfigScript {
    Hub _hub;
    final Uri _url;

    ConfigScript(Uri this._url) :
        _hub = Hub.root;

    Future<List<dynamic>> run() {
        var c = new Completer<List<dynamic>>();

        Comms.httpGet(_url).then((yamlText) {
            List<Map<String, Map>> commands = loadYaml(yamlText);

            Future<List<dynamic>> results = Commands.run(_executeCommandAsync, commands);
            results.then((_) {
                // we don't eactually use the results...
                Hub.root.events.LoadScriptCompleted.fire(_url);
                c.complete(results);
            });
        });

        return c.future;
    }

    Future<dynamic> _executeCommandAsync(Map command) {
        assert(command.keys.length == 1);
        String key = command.keys.first;
        Map data = command[key];

        log("Script command: $key");

        switch (key) {
            case "layers":
                return _doCommand_layers(data);
            case "camera":
                return _doCommand_camera(data);
            case "display":
                return _doCommand_display(data);
            case "wps":
                return _doCommand_wps(data);
        }

        Hub.error("Unrecognized command in configuration file", info: {
            "Command": key
        });
        return null;
    }

    Future _doCommand_wps(Map data) {
        //OgcDocumentTests.test();

        var proxy = YamlUtils.getOptionalSettingAsUri(data, "proxy");
        var url = YamlUtils.getRequiredSettingAsUri(data, "url");
        var description = YamlUtils.getOptionalSettingAsString(data, "description");
        var wps = new WpsService(url, proxy: proxy, description: description);
        wps.open();

        wps.getCapabilitiesAsync().then((OgcDocument doc) {
            assert(doc is Ogc_Capabilities);
            //log(doc);
        });

        wps.getProcessDescriptionAsync("groovy:wpshello").then((OgcDocument doc) {
            assert(doc is Ogc_ProcessDescription);
            //log(doc);
        });

        var params = {
            "alpha": "17",
            "beta": "11"
        };

        wps.executeProcessAsync("groovy:wpshello", params).then((OgcDocument doc) {
            assert(doc is Ogc_ExecuteResponse);
            Ogc_ExecuteResponse resp = doc;
            var status = resp.status.processSucceeded;
            assert(status != null);
            Ogc_DataType datatype = resp.processOutputs.outputData[0].data;
            Ogc_LiteralData48 literalData = datatype.literalData;
            log(literalData);
        });

        _hub.wps = wps;

        return new Future((){});
    }


    Future _doCommand_camera(Map data) {
        assert(data.containsKey("eye"));
        assert(data.containsKey("target"));
        if (!data.containsKey("up")) {
            data["up"] = [0.0, 0.0, 1.0];
        }
        if (!data.containsKey("fov")) {
            data["fov"] = 60.0;
        }

        List<num> eyelist = data["eye"];
        var eye = new Cartographic3.fromList(eyelist);

        List<num> targetlist = data["target"];
        var target = new Cartographic3.fromList(targetlist);

        List<num> uplist = data["up"];
        var up = new Cartesian3.fromList(uplist);

        double fov = data["fov"].toDouble();

        var cameraData = new CameraData(eye, target, up, fov);
        _hub.commands.updateCamera(cameraData);

        return new Future((){});
    }

    Future _doCommand_display(Map data) {
        if (data.containsKey("bbox")) {
            _hub.commands.displayBbox(data["bbox"]);
        }
        if (data.containsKey("colorize")) {
            Map colorizeData = data["colorize"];
            assert(colorizeData.containsKey("ramp"));
            String ramp = colorizeData["ramp"];
            assert(colorizeData.containsKey("dimension"));
            String dimName = colorizeData["dimension"];
            var f = _hub.commands.colorizeLayers(new ColorizeLayersData(ramp, dimName));
        }

        return new Future((){});
    }

    Future<List<Layer>> _doCommand_layers(Map layers) {
        var futures = [];

        for (var name in layers.keys) {
            var f = _hub.commands.addLayer(new LayerData(name, layers[name]));
            futures.add(f);
        }

        return Future.wait(futures);
    }
}
