// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.backend;


/// Base class for representing a "layer" in the viewer.
///
/// A layer may be an image, a point cloud, a GeoJSON shape, a base map, etc.
///
/// At this base level, layers really only must have a name (which must be unique). Some layers also
/// have an associated URL, bounding box, and description.
abstract class Layer {
    final RialtoBackend backend;

    final String type;
    final String name;
    final String description;

    final Uri url;
    final Uri proxy;

    CartographicBbox _bbox;

    Layer(RialtoBackend this.backend, String this.type, String this.name, Map map)
            : url = ConfigUtils.getOptionalSettingAsUrl(map, "url"),
              proxy = ConfigUtils.getOptionalSettingAsUrl(map, "proxy"),
              description = ConfigUtils.getOptionalSettingAsString(map, "description");
    requireUrl() {
        if (url != null) return;
        throw new ArgumentError("url not set in config file");
    }

    String get urlString => url.toString();
    String get proxyString => (proxy == null) ? null : proxy.toString();

    Future load(); // "add"
    Future unload(); // "remove"

    CartographicBbox get bbox => _bbox;
    set bbox(CartographicBbox v) => _bbox = v;

    bool get canZoomTo => (bbox != null);
}


/// Interface class for a layer that can be turned on and off
abstract class VisibilityControl {
    bool get visible;
    set visible(bool v);
}


/// Interface class for a layer that has a displayed bounding box that can be turned on and off
abstract class BboxVisibilityControl {
    bool get bboxVisible;
    set bboxVisible(bool v);
}


/// Interface class for a layer that can have its alpha transparency set
abstract class AlphaControl {
    double get alpha;
    set alpha(double d);
}


/// Interface class for a layer that can have saturation, gamma, etc set
abstract class ColorCorrectionControl {
    double get brightness;
    set brightness(double d);

    double get contrast;
    set contrast(double d);

    double get hue;
    set hue(double d);

    double get saturation;
    set saturation(double d);

    double get gamma;
    set gamma(double d);
}


/// Interface class for a layer that can be colorized
///
/// This really only applies to point cloud layers.
abstract class ColorizerControl {
    ColorizerData get colorizerData;
    set colorizerData(ColorizerData data);
}
