// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class AboutVM extends DialogVM {

    Hub _hub;

    AboutVM(String id) : super(id, hasCancelButton: false) {
    }

    @override
    void _show() {}

    @override
    void _hide(bool okay) {}
}
