// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

/// UI component for a "dialog"
abstract class DialogVM extends FormVM {
  bool _hasCancelButton;
  HtmlElement _dialogElement;
  var _dialogProxy;
  bool _skipStateTest;

  DialogVM(RialtoFrontend frontend, String id, {bool hasCancelButton: true, bool skipStateTest: false})
      : super(frontend, id),
        _hasCancelButton = hasCancelButton,
        _skipStateTest = skipStateTest {
    _dialogProxy = _backend.js.registerDialog(id);

    _dialogElement = _element;
    assert(_dialogElement != null);

    var openButton = querySelector("#" + openButtonId);
    if (openButton != null) {
      openButton.onClick.listen((ev) => show());
    }

    var okayButton = querySelector("#" + okayButtonId);
    assert(okayButton != null);
    okayButton.onClick.listen((e) => hide(true));

    if (_hasCancelButton) {
      var cancelButton = querySelector("#" + cancelButtonId);
      assert(cancelButton != null);
      cancelButton.onClick.listen((e) => hide(false));
    }
  }

  String get openButtonId => id + "_open";
  String get okayButtonId => id + "_okay";
  String get cancelButtonId => id + "_cancel";

  void show() {
    _backend.js.showDialog(_dialogProxy);
    _stateTracker.saveState();
    _show();
  }

  void hide(bool okay) {
    if (_skipStateTest) {
      _hide();
    } else {
      if (!okay) {
        _stateTracker.restoreState();
      } else {
        _hide();
      }
    }
    _backend.js.hideDialog(_dialogProxy);
  }

  // must be called only after temporaryHide()
  void temporaryShow() {
    _backend.js.showDialog(_dialogProxy);
    _stateTracker.restoreState();
    _show();
  }

  // must be called only before a temporaryShow()
  void temporaryHide() {
    _stateTracker.saveState();
    _backend.js.hideDialog(_dialogProxy);
  }

  // derived dialogs may reimplement these
  void _show() {}
  void _hide() {} // only called on OK, not Cancel
}
