// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class BaseTerrainLayer extends Layer {

    dynamic _provider;

    static const int _SourceInvalid = 0;
    static const int _SourceEllipsoid = 1;
    static const int _SourceArcGis = 2;
    static const int _SourceCesiumSmall = 3;
    static const int _SourceCesiumStk = 4;
    static const int _SourceVrTheWorld = 5;
    static final Map<String, int> _sourceMap = {
        'ELLIPSOID': _SourceEllipsoid,
        'ARCGIS': _SourceArcGis,
        'CESIUM_SMALL': _SourceCesiumSmall,
        'CESIUM_STK': _SourceCesiumStk,
        'VR_THEWORLD': _SourceVrTheWorld
    };

    int source;

    static const _defaultArcGisKey =
            'KED1aF_I4UzXOHy3BnhwyBHU4l5oY6rO6walkmHoYqGp4XyIWUd5YZUC1ZrLAzvV40pR6gBXQayh0eFA8m6vPg..';
    String _arcGisApiKey;

    BaseTerrainLayer(String name, Map map)
            : super(name, map),
              _arcGisApiKey = YamlUtils.getOptionalSettingAsString(map, "arcGisApiKey", _defaultArcGisKey) {

        if (!_sourceMap.containsKey(uri.toString())) {
            throw new ArgumentError("invalid base image layer type");
        }
        source = _sourceMap[uri.toString()];
    }

    @override
    Future<bool> load() {

        switch (source) {

            case _SourceEllipsoid:
                _provider = _hub.cesium.setEllipsoidBaseTerrainProvider();
                break;

            case _SourceArcGis:
                _provider = _hub.cesium.setArcGisBaseTerrainProvider(_arcGisApiKey);
                break;

            case _SourceCesiumSmall:
                var url = '//cesiumjs.org/smallterrain';
                var credit = 'Terrain data courtesy Analytical Graphics, Inc.';
                _provider = _hub.cesium.setCesiumBaseTerrainProvider(url, credit);
                break;

            case _SourceCesiumStk:
                var url = '//cesiumjs.org/stk-terrain/tilesets/world/tiles';
                _provider = _hub.cesium.setCesiumBaseTerrainProvider(url, null);
                break;

            case _SourceVrTheWorld:
                var url = '//www.vr-theworld.com/vr-theworld/tiles1.0.0/73/';
                _provider = _hub.cesium.setVrTheWorldBaseTerrainProvider(url);
                break;

            default:
                throw new ArgumentError("inbalid base terrain source");
        }

        return new Future(() {});
    }
}
