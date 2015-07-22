// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend;

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
  RialtoBackend _backend;
  String _configYaml;
  Uri _configUri;

  /// Creates a script parser/executer. Do not call this directly.
  ConfigScript(RialtoBackend this._backend);

  static ConfigScript fromUrl(RialtoBackend backend, Uri uri) {
    var c = new ConfigScript(backend);
    c._configUri = uri;
    c._configYaml = null;
    return c;
  }

  static ConfigScript fromYaml(RialtoBackend backend, String yaml) {
    var c = new ConfigScript(backend);
    c._configUri = null;
    c._configYaml = yaml;
    return c;
  }

  String get configYaml => _configYaml;
  Uri get configUri => _configUri;

  /// Loads a script from the [uri] and asynchronously executes the commands in it
  ///
  /// Returns a list with each command's result
  ///
  /// Throws or calls [Rialto.error] if there is a problem executing a command.
  Future<List<dynamic>> load() async {
    if (_configUri != null) {
      Http.Response response = await Utils.httpGet(_configUri);
      _configYaml = response.body;
    }

    var c = new Future(() => _executeCommands());
    return c;
  }

  Future<List<dynamic>> _executeCommands() {
    List<Map<String, Map>> commands;
    try {
      commands = loadYaml(_configYaml);
    } catch (e) {
      RialtoBackend.error("Unable to parse configuration", e);
      return null;
    }

    var results = _executeCommandsInList(_executeCommand, commands);

    results.then((_) => _backend.events.LoadScriptCompleted.fire(_configUri.toString()));

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
      case "wps":
        return _doCommand_wps(data);
    }

    RialtoBackend.error("Unrecognized command in configuration file", "Command: $key");
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

  static Future _executeNextCommand(
      ChainCommndFunction f, List<dynamic> inputs, int index, List<dynamic> outputs, Completer c) {
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
    var wps = new WpsService(_backend, url, proxyUri: proxyUri, description: description);
    wps.open();

    _backend.wps = wps;

    return wps.readProcessList();
  }

  Future _doCommand_camera(Map yamlData) {
    Map data = new Map.from(yamlData);

    assert(data.containsKey("longitude"));
    assert(data.containsKey("latitude"));
    assert(data.containsKey("height"));
    assert(data.containsKey("heading"));
    assert(data.containsKey("pitch"));
    assert(data.containsKey("roll"));

    double longitude = data["longitude"].toDouble();
    double latitude = data["latitude"].toDouble();
    double height = data["height"].toDouble();
    double heading = data["heading"].toDouble();
    double pitch = data["pitch"].toDouble();
    double roll = data["roll"].toDouble();

    _backend.commands.zoomToCustom(longitude, latitude, height, heading, pitch, roll);

    return new Future(() {});
  }

  Future<List<Layer>> _doCommand_layers(List layers) {
    var futures = [];

    for (Map layermap in layers) {
      assert(layermap is Map);
      assert(layermap.length == 1);
      var name = layermap.keys.first;
      var data = layermap[name];
      var f = _backend.commands.addLayer(name, data);
      futures.add(f);
    }

    return Future.wait(futures);
  }

  static Map<String, Uri> get defaultServers {
    Uri viewerServer;
    Uri geopackageServer;
    Uri dataServer;
    Uri wpsServer;
    Uri wpsProxyServer;

    Uri uri = Uri.parse(window.location.href);

    var mode;
    if (uri.host == "localhost") {
      mode = DeploymentMode.LocalAll;
    } else if (uri.host.startsWith("viewerserver")) {
      mode = DeploymentMode.Tutum;
    } else if (uri.host == "192.168.59.103") {
      mode = DeploymentMode.DockerAll;
    } else {
      mode = DeploymentMode.LocalAll;
    }

    switch (mode) {
      case DeploymentMode.LocalAll:
        RialtoBackend.log("Using deployment mode 'LocalAll'");
        viewerServer = uri;
        geopackageServer = uri.replace(port: GeoPackageServerPort, path: RootPath);
        dataServer = uri.replace(port: DataServerPort, path: RootPath);
        wpsServer = uri.replace(port: WpsServerPort, path: WpsServerPath);
        wpsProxyServer = uri.replace(port: WpsProxyServerPort, path: RootPath);
        break;
      case DeploymentMode.DockerServices:
        RialtoBackend.log("Using deployment mode 'DockerServices'");
        viewerServer = uri;
        uri = uri.replace(host: "192.168.59.103");
        geopackageServer = uri.replace(port: GeoPackageServerPort, path: RootPath);
        dataServer = uri.replace(port: DataServerPort, path: RootPath);
        wpsServer = uri.replace(port: WpsServerPort, path: WpsServerPath);
        wpsProxyServer = uri.replace(port: WpsProxyServerPort, path: RootPath);
        break;
      case DeploymentMode.DockerAll:
        RialtoBackend.log("Using deployment mode 'DockerAll'");
        viewerServer = uri;
        geopackageServer = uri.replace(port: GeoPackageServerPort, path: RootPath);
        dataServer = uri.replace(port: DataServerPort, path: RootPath);
        wpsServer = uri.replace(port: WpsServerPort, path: WpsServerPath);
        wpsProxyServer = uri.replace(port: WpsProxyServerPort, path: RootPath);
        break;
      case DeploymentMode.Tutum:
        RialtoBackend.log("Using deployment mode 'Tutum'");
        viewerServer = uri;
        var host = uri.host;
        var geopackageServerHost = host.replaceAll("viewerserver.", "geopackageserver.");
        var dataServerHost = host.replaceAll("viewerserver.", "dataserver.");
        var wpsServerHost = host.replaceAll("viewerserver.", "wpsserver.");
        var wpsProxyServerHost = host.replaceAll("viewerserver.", "wpsproxyserver.");

        geopackageServer = uri.replace(host: geopackageServerHost, port: GeoPackageServerPort, path: RootPath);
        dataServer = uri.replace(host: dataServerHost, port: DataServerPort, path: RootPath);
        wpsServer = uri.replace(host: wpsServerHost, port: WpsServerPort, path: WpsServerPath);
        wpsProxyServer = uri.replace(host: wpsProxyServerHost, port: WpsProxyServerPort, path: RootPath);
        break;
    }

    return {
      "viewer": viewerServer,
      "geopackage": geopackageServer,
      "data": dataServer,
      "wps": wpsServer,
      "wpsproxy": wpsProxyServer
    };
  }

  static Uri get defaultUri {
    var uri = defaultServers["data"].replace(path: "/demo.yaml");
    return uri;
  }

  static String get defaultYaml {
    var servers = defaultServers;

    String yaml = """
- layers:
    - basemap:
        type: bing_base_imagery
        #style: Road
        style: Aerial
    - pointcloud:
        type: pointcloud
        url: ${servers["geopackage"].toString()}/serp-small/mytablename
    - alberta_poly:
        type: geojson
        url: ${servers["data"].toString()}/alberta.json

- wps:
    proxy: ${servers["wpsproxy"].toString()}
    url: ${servers["wps"].toString()}
""";

    return yaml;
  }
}

final GeoPackageServerPort = 42422;
final WpsServerPort = 42423;
final DataServerPort = 42424;
final WpsProxyServerPort = 42425;

final WpsServerPath = "/geoserver/ows";
final RootPath = "";

enum DeploymentMode {
  LocalAll, // viewer and services running manually on localhost
  DockerServices, // viewer on localhost, services via docker
  DockerAll, // viewer and services on docker
  Tutum // viewer and services on tutum stack
}
