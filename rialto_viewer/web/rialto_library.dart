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

part 'backend/commands.dart';
part 'backend/config_script.dart';
part 'backend/event_registry.dart';
part 'backend/rialto_backend.dart';
part 'backend/layer_manager.dart';
part 'backend/viewshedder.dart';

part 'backend/cesium/bbox_shape.dart';
part 'backend/cesium/cesium_bridge.dart';

part 'backend/layers/layer.dart';
part 'backend/layers/base_imagery_layer.dart';
part 'backend/layers/base_terrain_layer.dart';
part 'backend/layers/imagery_layer.dart';
part 'backend/layers/point_cloud_layer.dart';
part 'backend/layers/terrain_layer.dart';
part 'backend/layers/geojson_layer.dart';

part 'backend/ogc/ogc_document_tests.dart';
part 'backend/ogc/ogc_document.dart';
part 'backend/ogc/ogc_service.dart';
part 'backend/ogc/wps_job_manager.dart';
part 'backend/ogc/wps_service.dart';
part 'backend/ogc/wps_service_tests.dart';

part 'frontend/ui_components/about_dialog.dart';
part 'frontend/ui_components/advanced_settings_dialog.dart';
part 'frontend/ui_components/camera_settings_dialog.dart';
part 'frontend/ui_components/layer_adder_dialog.dart';
part 'frontend/ui_components/layer_customization_dialog.dart';
part 'frontend/ui_components/layer_info_dialog.dart';
part 'frontend/ui_components/load_configuration_dialog.dart';
part 'frontend/ui_components/layer_manager_dialog.dart';

part 'backend/utils/cartesian3.dart';
part 'backend/utils/cartographic3.dart';
part 'backend/utils/color.dart';
part 'backend/utils/js_bridge.dart';
part 'backend/utils/signal.dart';
part 'backend/utils/utils.dart';
part 'backend/utils/config_utils.dart';

part 'frontend/viewmodels/check_box_vm.dart';
part 'frontend/viewmodels/dialog_vm.dart';
part 'frontend/viewmodels/button_vm.dart';
part 'frontend/viewmodels/list_box_vm.dart';
part 'frontend/viewmodels/rialto_frontend.dart';
part 'frontend/viewmodels/text_input_vm.dart';
part 'frontend/viewmodels/view_model.dart';
