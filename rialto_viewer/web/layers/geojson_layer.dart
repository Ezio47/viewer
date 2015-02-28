// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class GeoJsonLayer extends UrlLayer implements VisibilityControl {
    dynamic _dataSource;
    bool _visible;

    GeoJsonLayer(String name, Map map)
            : _visible = YamlUtils.getOptionalSettingAsBool(map, "visible", true),
              super("geojson", name, map);

    @override set visible(bool v) {
        _hub.cesium.setDataSourceVisible(_dataSource, v);
        _visible = v;
    }
    @override bool get visible => _visible;

    void _forceUpdates() {
        visible = _visible;
    }

    @override
    Future<bool> load() {
        Completer c = new Completer();

        _hub.cesium.addGeoJson(name, _url.toString()).then((ds) {
            _dataSource = ds;


            // TODO: set bbox

            _forceUpdates();

            c.complete(true);
        });

        return c.future;
    }
}
