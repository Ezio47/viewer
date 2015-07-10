// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

class LayerInfoDialog extends DialogVM {
  PreElement _preElement;

  LayerInfoDialog(RialtoFrontend frontend, String id) : super(frontend, id, hasCancelButton: false) {
    _preElement = querySelector("#infoDialog_body");
  }

  @override
  void _show() {
    String str = "";

    for (var layer in _backend.layerManager.layers) {
      str += _getLayerInfo(layer);
    }

    _preElement.text = str;
  }

  String _getLayerInfo(Layer layer) {
    String str = "";

    str += "Source\n";
    str += "======\n";

    str += "  Name: ${layer.name}\n";
    str += "  Type: ${layer.type}\n";
    str += "  Description: ${layer.description}\n";

    if (layer.url != null) {
      final url = layer.url.toString();
      str += "  URL: $url";
      if (layer.proxy != null) {
        final proxy = layer.proxy.toString();
        str += "  Proxy: $proxy\n";
      }
    }

    if (layer.bbox != null) {
      str += "\n";
      str += "Bounding Box\n";
      str += "============\n";

      final precision = _backend.displayPrecision;

      final minx = layer.bbox.minimum.longitude.toStringAsFixed(precision);
      final miny = layer.bbox.minimum.latitude.toStringAsFixed(precision);
      final minz = layer.bbox.minimum.height.toStringAsFixed(precision);
      final maxx = layer.bbox.maximum.longitude.toStringAsFixed(precision);
      final maxy = layer.bbox.maximum.latitude.toStringAsFixed(precision);
      final maxz = layer.bbox.maximum.height.toStringAsFixed(precision);

      str += "  Min X: $minx\n";
      str += "  Min Y: $miny\n";
      str += "  Min Z: $minz\n";
      str += "  Max X: $maxx\n";
      str += "  Max Y: $maxy\n";
      str += "  Max Z: $maxz\n";
    }

    if (layer is PointCloudLayer) {
      str += "\n";
      str += "Point Cloud\n";
      str += "===========\n";

      str += "  Nuymber of points: ${layer.numPoints.toString()}\n";
    }

    str += "\n\n";

    return str;
  }

  @override
  void _hide() {}
}
