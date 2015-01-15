// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


abstract class ViewModel {
    String _id;
    Element _element;

    ViewModel(String this._id) {
        assert(!_id.startsWith("#"));

        _element = querySelector("#" + _id);
        assert(_element != null);
    }
}
