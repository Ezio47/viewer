// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


abstract class ViewModel {
    final String id;
    Element _element;

    ViewModel(String this.id) {
        assert(id.startsWith("#"));

        _element = querySelector(id);
        if (_element == null) {
            throw new ArgumentError("HTML element with id=$id not found");
        }
    }
}
