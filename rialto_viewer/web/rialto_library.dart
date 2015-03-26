// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

/// Imports all the parts of the viewer.

library rialto.viewer;

import 'dart:async';
import 'dart:html';
import 'dart:js';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/browser_client.dart' as BHttp;
import 'package:http/http.dart' as Http;
import 'package:vector_math/vector_math.dart';
import 'package:xml/xml.dart' as Xml;
import 'package:yaml/yaml.dart';

part 'commands.dart';
part 'config_script.dart';
part 'event_registry.dart';
part 'rialto_backend.dart';
part 'layer_manager.dart';
part 'viewshedder.dart';

part 'cesium/bbox_shape.dart';
part 'cesium/cesium_bridge.dart';

part 'layers/layer.dart';
part 'layers/base_imagery_layer.dart';
part 'layers/base_terrain_layer.dart';
part 'layers/imagery_layer.dart';
part 'layers/point_cloud_layer.dart';
part 'layers/terrain_layer.dart';
part 'layers/geojson_layer.dart';

part 'ogc/ogc_document.dart';
part 'ogc/ogc_document_tests.dart';
part 'ogc/ogc_service.dart';
part 'ogc/wps_job_manager.dart';
part 'ogc/wps_service.dart';
part 'ogc/wps_service_tests.dart';

part 'ui_components/about_dialog.dart';
part 'ui_components/advanced_settings_dialog.dart';
part 'ui_components/camera_settings_dialog.dart';
part 'ui_components/layer_adder_dialog.dart';
part 'ui_components/layer_customization_dialog.dart';
part 'ui_components/layer_info_dialog.dart';
part 'ui_components/load_configuration_dialog.dart';
part 'ui_components/layer_manager_dialog.dart';

part 'utils/cartesian3.dart';
part 'utils/cartographic3.dart';
part 'utils/color.dart';
part 'utils/js_bridge.dart';
part 'utils/signal.dart';
part 'utils/utils.dart';
part 'utils/config_utils.dart';

part 'viewmodels/check_box_vm.dart';
part 'viewmodels/dialog_vm.dart';
part 'viewmodels/button_vm.dart';
part 'viewmodels/list_box_vm.dart';
part 'viewmodels/rialto_frontend.dart';
part 'viewmodels/text_input_vm.dart';
part 'viewmodels/view_model.dart';
