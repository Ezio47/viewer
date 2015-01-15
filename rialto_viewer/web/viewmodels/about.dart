// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class AboutVM extends DialogVM {

    Hub _hub;

    AboutVM(DialogElement dialogElement, var dollar) : super(dialogElement, dollar, hasCancelButton: false) {
    }

    @override
    void _open() {}

    @override
    void _close(bool okay) {}
}
