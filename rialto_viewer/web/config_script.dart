// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class ConfigScript {
    Hub _hub;
    final Uri _url;

    ConfigScript(Uri this._url) : _hub = Hub.root;

    Future<List<dynamic>> run() {
        var c = new Completer<List<dynamic>>();

        Comms.httpGet(_url).then((Http.Response response) {
            String yamlText = response.body;
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
        Object data = command[key];

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

        var proxyUri = YamlUtils.getOptionalSettingAsUrl(data, "proxy");
        var url = YamlUtils.getRequiredSettingAsUrl(data, "url");
        var description = YamlUtils.getOptionalSettingAsString(data, "description");
        var wps = new WpsService(url, proxyUri: proxyUri, description: description);
        wps.open();

        //WpsServiceTest.test(wps);

        _hub.wps = wps;

        return new Future(() {});
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

        return new Future(() {});
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
            _hub.commands.colorizeLayers(new ColorizerData(ramp, dimName));
        }

        return new Future(() {});
    }

    Future<List<Layer>> _doCommand_layers(List layers) {
        var futures = [];

        for (Map layermap in layers) {
            assert(layermap is Map);
            assert(layermap.length == 1);
            var name = layermap.keys.first;
            var data = layermap[name];
            var f = _hub.commands.addLayer(new LayerData(name, data));
            futures.add(f);
        }

        return Future.wait(futures);
    }
}
