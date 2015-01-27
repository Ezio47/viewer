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

        Map commands = JSON.decode(json);

        for (String command in commands.keys) {

            var data = commands[command];

            switch (command) {
                case "layers":
                    _doCommand_layers(data);
                    break;
                case "camera":
                    _doCommand_camera(data);
                    break;
                default:
                    assert(false);
            }
        }
    }

    void _doCommand_camera(Map data) {
        assert(data.containsKey("eye"));
        assert(data.containsKey("target"));
        assert(data.containsKey("fov"));
        List<num> eye = data["eye"];
        List<num> target = data["target"];
        num fov = data["fov"];

        log("Camera command: $eye .. $target .. $fov");
    }

    void _doCommand_layers(List layers) {
        for (Map map in layers) {
            Hub.root.layerManager.createLayer(map);
        }
    }
}
