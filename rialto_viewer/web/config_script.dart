// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class ConfigScript {
    Hub _hub;

    ConfigScript(String url) {
        _hub = Hub.root;

        Comms.httpGet(url).then((yamlText) {
            List<Map<String, Map>> commands = loadYaml(yamlText);

            List<dynamic> results = [];
            var c = new Completer();
            _executeNextCommand(commands, 0, results, c).then((ok) {
            });
        });

        Hub.root.events.LoadScriptCompleted.fire(url);
    }

    Future _executeNextCommand(List<Map<String, Map>> commands, int index, List<dynamic> results, Completer c) {

        Map command = commands[index];

        assert(command.keys.length == 1);
        String key = command.keys.first;
        Map data = command[key];

        _executeCommandAsync(key, data).then((dynamic result) {
            log("command done: $key");

            results.add(result);

            if (index + 1 != commands.length) {
                _executeNextCommand(commands, index + 1, results, c);
            } else {
                c.complete();
                return;
            }
        });

        return c.future;
    }

    Future<dynamic> _executeCommandAsync(String key, Map data) {

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

        var proxy = YamlUtils.getOptionalSettingAsString(data, "proxy");
        var server = YamlUtils.getRequiredSettingAsString(data, "server");
        var description = YamlUtils.getOptionalSettingAsString(data, "description");
        var wps = new WpsService(server, proxy: proxy, description: description);
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

        var c = new Completer();
        c.complete();
        return c.future;
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
        _hub.events.UpdateCamera.fire(cameraData);

        var c = new Completer();
        c.complete();
        return c.future;
    }

    Future _doCommand_display(Map data) {
        if (data.containsKey("bbox")) {
            _hub.events.DisplayBbox.fire(data["bbox"]);
        }
        if (data.containsKey("colorize")) {
            Map colorizeData = data["colorize"];
            assert(colorizeData.containsKey("ramp"));
            String ramp = colorizeData["ramp"];
            assert(colorizeData.containsKey("dimension"));
            String dimName = colorizeData["dimension"];
            _hub.events.ColorizeLayers.fire(new ColorizeLayersData(ramp, dimName));
        }

        var c = new Completer();
        c.complete();
        return c.future;
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
