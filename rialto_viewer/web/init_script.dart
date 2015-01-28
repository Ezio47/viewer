// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class InitScript {
    InitScript(String url) {
        Http.Client client = new BHttp.BrowserClient();

        Future<String> f = client.get(url).then((response) {
            //print(r.runtimeType);
            //print(response.body);
            return response.body;
        }).catchError((e) {
            log("ERROR: $e");
            assert(false);
        });

        f.then((s) => _execute(s));

        Hub.root.eventRegistry.LoadScriptCompleted.fire(url);
    }

    void _execute(String json) {
        Hub.root.layerManager.layers.clear();

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
                case "colorize":
                    _doCommand_colorize(data);
                    break;
                default:
                    assert(false);
            }
        }
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
        Hub.root.eventRegistry.UpdateCamera.fire(cameraData);
    }

    void _doCommand_colorize(Map data) {
        assert(data.containsKey("ramp"));
        String ramp = data["ramp"];
        Hub.root.eventRegistry.ColorizeLayers.fire(ramp);
    }

    void _doCommand_display(Map data) {
        if (data.containsKey("bbox")) {
            Hub.root.eventRegistry.DisplayBbox.fire(data["bbox"]);
        }
    }

    void _doCommand_layers(Map layers) {
        for (var name in layers.keys) {
            Hub.root.eventRegistry.AddLayer.fire(new LayerData(name, layers[name]));
        }
    }
}
