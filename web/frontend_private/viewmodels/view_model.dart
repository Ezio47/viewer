// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

/// base class for Rialto's notion of a UI component
abstract class ViewModel {
  RialtoFrontend _frontend;
  RialtoBackend _backend;
  final String id;
  Element _element;

  /// Create a view model for the given HTML element
  ///
  ViewModel(RialtoFrontend this._frontend, String this.id) {
    assert(!id.startsWith("#"));

    _backend = _frontend.backend;

    _element = querySelector("#" + id);
    if (_element == null) {
      throw new ArgumentError("HTML element with id=$id not found");
    }
  }
}
