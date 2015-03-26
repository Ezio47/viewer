// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

// TODO: document the allowed commands in the config script

typedef Future<dynamic> ChainCommndFunction(dynamic);

/// Parser and executor functions for the configuration file.
///
/// Invoked by [main] to issue commands to the viewer.
///
/// The script format is a YAML list. Each list element is a command, such as "layers" or "wps".
/// Each command has it's own list of options. Example:
///     - layers:
///         - bing:
///             type: bing_base_imagery
///             style: Aerial
///
/// Each command in the script has it's own function in this class ("_doCommand_NAME()");
class ConfigScript {
    Rialto _rialto;

    /// Creates a script parser/executer.
    ConfigScript() : _rialto = Rialto.root;

    /// Loads a script from the [uri] and asynchronously executes the commands in it
    ///
    /// Returns a list with each command's result
    ///
    /// Throws or calls [Rialto.error] if there is a problem executing a command.
    Future<List<dynamic>> loadFromUrl(Uri url) async {
        var c = new Completer<List<dynamic>>();

        Http.Response response = await Utils.httpGet(url);
        String yamlText = response.body;

        return _executeCommands(yamlText, url.toString());
    }

    /// Loads a script from the string [yamlText] and asynchronously executes the commands in it
    ///
    /// Returns a list with each command's result
    ///
    /// Throws or calls [Rialto.error] if there is a problem executing a command.
    Future<List<dynamic>> loadFromString(String yamlText) async {

        List<dynamic> results = await _executeCommands(yamlText, "");

        return results;
    }

    Future<List<dynamic>> _executeCommands(String yamlText, String urlString) async {

        List<Map<String, Map>> commands;
        try {
            commands = loadYaml(yamlText);
        } catch (e) {
            Rialto.error("Unable to parse configuration", e);
            return null;
        }

        var results = _executeCommandsInList(_executeCommand, commands);

        results.then((_) => Rialto.root.events.LoadScriptCompleted.fire(urlString));

        return results;
    }

    Future<dynamic> _executeCommand(Map command) {
        assert(command.keys.length == 1);
        String key = command.keys.first;
        Object data = command[key];

        //log("Script command: $key");

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

        Rialto.error("Unrecognized command in configuration file", "Command: $key");
        return null;
    }

    // given a list of things, run a function F against each one, in order
    // and with an explicit wait between each one
    //
    // and return a Future with the list of the results from each F
    static Future<List<dynamic>> _executeCommandsInList(ChainCommndFunction f, List<dynamic> inputs) {
        List<dynamic> outputs = [];
        var c = new Completer();

        _executeNextCommand(f, inputs, 0, outputs, c).then((_) {});

        return c.future;
    }

    static Future _executeNextCommand(ChainCommndFunction f, List<dynamic> inputs, int index, List<dynamic> outputs,
            Completer c) {
        dynamic input = inputs[index];

        f(input).then((dynamic result) {
            outputs.add(result);

            if (index + 1 != inputs.length) {
                _executeNextCommand(f, inputs, index + 1, outputs, c);
            } else {
                c.complete(outputs);
                return;
            }
        });

        return c.future;
    }

    Future _doCommand_wps(Map data) {

        var proxyUri = ConfigUtils.getOptionalSettingAsUrl(data, "proxy");
        var url = ConfigUtils.getRequiredSettingAsUrl(data, "url");
        var description = ConfigUtils.getOptionalSettingAsString(data, "description");
        var wps = new WpsService(url, proxyUri: proxyUri, description: description);
        wps.open();

        //WpsServiceTest.test(wps);

        _rialto.wps = wps;

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

        _rialto.commands.zoomTo(eye, target, up, fov);

        return new Future(() {});
    }

    Future _doCommand_display(Map data) {
        if (data.containsKey("colorize")) {
            Map colorizeData = data["colorize"];
            assert(colorizeData.containsKey("ramp"));
            String ramp = colorizeData["ramp"];
            assert(colorizeData.containsKey("dimension"));
            String dimName = colorizeData["dimension"];
            _rialto.commands.colorizeLayers(new ColorizerData(ramp, dimName));
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
            var f = _rialto.commands.addLayer(new LayerData(name, data));
            futures.add(f);
        }

        return Future.wait(futures);
    }
}
