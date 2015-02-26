// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class YamlUtils {
    static final Type _stringType = ("").runtimeType;
    static final Type _intType = (0).runtimeType;
    static final Type _boolType = (false).runtimeType;
    static final Type _doubleType = (0.0).runtimeType;
    static final Type _list4Type = [4].runtimeType;

    static dynamic _getRequiredSettingAsType(Map map, String key, Type type) {
        if (!map.containsKey(key)) {
            throw new ArgumentError("required setting '$key' not found");
        }

//        if (type == _stringType && map[key].runtimeType != type) {
//            return map[key].toString();
//        }

        assert(map[key].runtimeType == type);
        return map[key];
    }

    static dynamic _getOptionalSettingAsType(Map map, String key, Type type, dynamic defalt) {
        assert(defalt == null || defalt.runtimeType == type);
        if (!map.containsKey(key)) {
            return defalt;
        }
        assert(map[key].runtimeType == type);
        return map[key];
    }

    static String getRequiredSettingAsString(Map map, String key) => _getRequiredSettingAsType(map, key, _stringType);

    static Uri getRequiredSettingAsUri(Map map, String key) {
        var s = _getRequiredSettingAsType(map, key, _stringType);
        var u = Uri.parse(s);
        return u;
    }

    static int getRequiredSettingAsInt(Map map, String key) => _getRequiredSettingAsType(map, key, _intType);

    static String getOptionalSettingAsString(Map map, String key, [String defalt = null]) =>
            _getOptionalSettingAsType(map, key, _stringType, defalt);

    static Uri getOptionalSettingAsUri(Map map, String key, [String defalt = null]) {
        String s = getOptionalSettingAsString(map, key, defalt);
        var u = Uri.parse(s);
        return u;
    }

    static List<num> getOptionalSettingAsList4(Map map, String key, [List<num> defalt = null]) =>
            _getOptionalSettingAsType(map, key, _list4Type, defalt);

    static int getOptionalSettingAsInt(Map map, String key, [int defalt = 0]) =>
            _getOptionalSettingAsType(map, key, _intType, defalt);

    static bool getOptionalSettingAsBool(Map map, String key, [bool defalt = false]) =>
            _getOptionalSettingAsType(map, key, _boolType, defalt);

    static bool _boolParse(String s) {
        s = s.toLowerCase();
        if (s == "true") return true;
        if (s == "false") return false;
        throw new FormatException("invalid boolean: $s");
    }
}
