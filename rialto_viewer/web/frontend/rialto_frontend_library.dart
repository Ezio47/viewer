// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

/// Imports all the parts of the viewer.

library rialto.frontend;

import 'dart:html';

import '../backend/rialto_backend_library.dart';

part 'ui_components/about_dialog.dart';
part 'ui_components/advanced_settings_dialog.dart';
part 'ui_components/camera_settings_dialog.dart';
part 'ui_components/layer_adder_dialog.dart';
part 'ui_components/layer_customization_dialog.dart';
part 'ui_components/layer_info_dialog.dart';
part 'ui_components/load_configuration_dialog.dart';
part 'ui_components/layer_manager_dialog.dart';

part 'viewmodels/check_box_vm.dart';
part 'viewmodels/dialog_vm.dart';
part 'viewmodels/button_vm.dart';
part 'viewmodels/list_box_vm.dart';
part 'viewmodels/text_input_vm.dart';
part 'viewmodels/view_model.dart';

part 'rialto_frontend.dart';
