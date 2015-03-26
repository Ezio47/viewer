// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class GeoJsonLayer extends Layer implements VisibilityControl {
    dynamic _dataSource;
    bool _visible;

    GeoJsonLayer(RialtoBackend backend, String name, Map map)
            : _visible = ConfigUtils.getOptionalSettingAsBool(map, "visible", true),
              super(backend, "geojson", name, map) {
        _requireUrl();
    }

    @override set visible(bool v) {
        _backend.cesium.setDataSourceVisible(_dataSource, v);
        _visible = v;
    }
    @override bool get visible => _visible;

    void _forceUpdates() {
        visible = _visible;
    }

    @override
    Future load() {
        Completer c = new Completer();

        _backend.cesium.addGeoJsonDataSource(name, urlString).then((ds) {
            _dataSource = ds;

            _forceUpdates();

            c.complete();
        });

        return c.future;
    }

    @override
    Future unload() {
        return new Future(() {
            _backend.cesium.removeDataSource(_dataSource);
        });
    }
}
