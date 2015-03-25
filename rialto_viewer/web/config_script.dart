// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class ConfigScript {
    Hub _hub;

    ConfigScript() : _hub = Hub.root;

    Future<List<dynamic>> loadFromUrlAsync(Uri url) async {
        var c = new Completer<List<dynamic>>();

        Http.Response response = await Comms.httpGet(url);
        String yamlText = response.body;

        List<dynamic> results = await _runInner(yamlText, url.toString());
        return results;
    }

    Future<List<dynamic>> loadFromStringAsync(String yamlText) async {

        List<dynamic> results = await _runInner(yamlText, "");

        return results;
    }

    Future<List<dynamic>> _runInner(String yamlText, String urlString) async {

        List<Map<String, Map>> commands;
        try {
            commands = loadYaml(yamlText);
        } catch (e) {
            Hub.error("Unable to parse configuration", e);
            return null;
        }

        List<dynamic> results = await Commands.run(_executeCommandAsync, commands);

        Hub.root.events.LoadScriptCompleted.fire(urlString);

        return results;
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

        Hub.error("Unrecognized command in configuration file", "Command: $key");
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
        data.putIfAbsent("up", () => [0.0, 0.0, 1.0]);

        data.putIfAbsent("fov", () => 60.0);

        List<num> eyelist = data["eye"];
        var eye = new Cartographic3.fromList(eyelist);

        List<num> targetlist = data["target"];
        var target = new Cartographic3.fromList(targetlist);

        List<num> uplist = data["up"];
        var up = new Cartesian3.fromList(uplist);

        double fov = data["fov"].toDouble();

        _hub.commands.zoomTo(eye, target, up, fov);

        return new Future(() {});
    }

    Future _doCommand_display(Map data) {
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
