// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class ConfigScript {
    Hub _hub;

    ConfigScript(String url) {
        _hub = Hub.root;

        Http.Client client = new BHttp.BrowserClient();

        Future<String> f = client.get(url).then((response) {
            return response.body;
        }).catchError((e) {
            log("ERROR: $e");
            assert(false); // TODO
        });

        f.then((s) {
            _hub.events.RemoveAllLayersCompleted.subscribe0(() {
                _execute(s);
            });

            _hub.events.RemoveAllLayers.fire0();
        });

        Hub.root.events.LoadScriptCompleted.fire(url);
    }

    void _execute(String json) {

        Map commands = loadYaml(json);

        if (commands.containsKey("layers")) {
            // do this first, since other things like colorize depend on it
            _doCommand_layers(commands["layers"]);
        }

        for (String command in commands.keys) {

            var data = commands[command];
            log("Script command: $command");

            switch (command) {
                case "layers":
                    // already handled
                    break;
                case "camera":
                    _doCommand_camera(data);
                    break;
                case "display":
                    _doCommand_display(data);
                    break;
                case "wps":
                    _doCommand_wps(data);
                    break;
                default:
                    assert(false); // TODO
            }
        }
    }

    void _doCommand_wps(Map data) {
        var proxy = YamlUtils.getRequiredSettingAsString(data, "proxy");
        var server = YamlUtils.getRequiredSettingAsString(data, "server");
        var description = YamlUtils.getOptionalSettingAsString(data, "description");
        var wps = new WpsService(server, proxy: proxy, description: description);
        wps.open();
        //wps.close();
        _hub.wps = wps;
    }


    void _doCommand_camera(Map data) {
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
    }

    void _doCommand_display(Map data) {
        if (data.containsKey("bbox")) {
            _hub.events.DisplayBbox.fire(data["bbox"]);
        }
        if (data.containsKey("colorize")) {
            Map colorizeData = data["colorize"];
            assert(colorizeData.containsKey("ramp"));
            String ramp = colorizeData["ramp"];
            assert(colorizeData.containsKey("dimension"));
            String dimName = colorizeData["dimension"];
            assert(dimName == "z");
            _hub.events.ColorizeLayers.fire(ramp);
        }
    }

    void _doCommand_layers(Map layers) {
        for (var name in layers.keys) {
            _hub.events.AddLayer.fire(new LayerData(name, layers[name]));
        }
    }
}
