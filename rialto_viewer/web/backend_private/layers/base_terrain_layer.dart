// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend.private;


abstract class BaseTerrainLayer extends Layer {

    dynamic _provider;

    BaseTerrainLayer(RialtoBackend backend, String type, String name, Map map) : super(backend, type, name, map);

    @override
    Future unload() {
        var f = new Future(() {
            backend.cesium.unsetBaseTerrainProvider();
        });
        return f;
    }
}


class EllipsoidBaseTerrainLayer extends BaseTerrainLayer {

    EllipsoidBaseTerrainLayer(RialtoBackend backend, String name, Map map)
            : super(backend, "ellipsoid_base_terrain", name, map);

    @override
    Future load() {
        var f = new Future(() {
            var options = {};
            _provider = backend.cesium.setEllipsoidBaseTerrainProvider(options);
        });
        return f;
    }
}


class ArcGisBaseTerrainLayer extends BaseTerrainLayer {

    static const _defaultKey =
            'KED1aF_I4UzXOHy3BnhwyBHU4l5oY6rO6walkmHoYqGp4XyIWUd5YZUC1ZrLAzvV40pR6gBXQayh0eFA8m6vPg..';
    static const _defaultUrl =
            '//elevation.arcgisonline.com/ArcGIS/rest/services/WorldElevation/DTMEllipsoidal/ImageServer';
    String _arcGisApiKey;

    ArcGisBaseTerrainLayer(RialtoBackend backend, String name, Map map)
            : super(backend, "arcgis_base_terrain", name, map),
              _arcGisApiKey = ConfigUtils.getOptionalSettingAsString(map, "arcGisApiKey", _defaultKey);

    @override
    Future load() {
        var f = new Future(() {

            var options = {
                'url': (url == null) ? _defaultUrl : url.toString(),
                'token': _defaultKey
            };

            _provider = backend.cesium.setArcGisBaseTerrainProvider(options);
        });
        return f;
    }
}


class CesiumSmallBaseTerrainLayer extends BaseTerrainLayer {

    CesiumSmallBaseTerrainLayer(RialtoBackend backend, String name, Map map)
            : super(backend, "cesium_small_base_terrain", name, map);

    @override
    Future load() {
        var f = new Future(() {
            var options = {
                'url': '//cesiumjs.org/smallterrain',
                'credit': 'Terrain data courtesy Analytical Graphics, Inc.'
            };
            _provider = backend.cesium.setCesiumBaseTerrainProvider(options);
        });
        return f;
    }
}


class CesiumStkBaseTerrainLayer extends BaseTerrainLayer {

    CesiumStkBaseTerrainLayer(RialtoBackend backend, String name, Map map)
            : super(backend, "cesium_stk_base_terrain", name, map);
    @override
    Future load() {
        var f = new Future(() {
            var options = {
                'url': '//cesiumjs.org/stk-terrain/tilesets/world/tiles'
            };
            _provider = backend.cesium.setCesiumBaseTerrainProvider(options);
        });
        return f;
    }
}


class VrTheWorldBaseTerrainLayer extends BaseTerrainLayer {

    VrTheWorldBaseTerrainLayer(RialtoBackend backend, String name, Map map)
            : super(backend, "vrtheworld_base_terrain", name, map);

    @override
    Future<bool> load() {
        var f = new Future(() {
            var options = {
                'url': '//www.vr-theworld.com/vr-theworld/tiles1.0.0/73/'
            };
            _provider = backend.cesium.setVrTheWorldBaseTerrainProvider(options);
        });
        return f;
    }
}
